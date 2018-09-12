%% This function is copied by a Toolbox from

function [rectIm1, rectIm2] = Rectify_copied( im1, im2, F, do_plot)
            %im1 = imread('img/L2.JPG');
            %im2 = imread('img/R2.JPG');
   
            %% Compute Epipole
            % calculate epipoles
            % of image 1 due to camera center in image 2 (right nullspace)
            eP1 = null(F);
            eP1 = eP1./eP1(3);
            % of image 2 due to camera center in image 1 (left nullspace)
            eP2 = null(F');
            eP2 = eP2./eP2(3);
            %% Compute Epiline
            

            
            
            %% find initial rectification matrices
            H1 = [   1              0       0;...
                    -eP1(2)/eP1(1)  1       0;...
                    -1/eP1(1)       0       1];
            
            A = [   -1             0            0       0            0            0;...
                    0              -1           0       0            0            0;...
                    0              0           -1       0            0            0;...
                    0              0            0       1            0            0;...
                    0              0            0       0            1            0;...
                    0              0            0       0            0            1;...
                    -H1(3,1)        0            0       H1(2,1)      0            0;...
                    0              -H1(3,1)      0       0            H1(2,1)      0;...
                    0              0           -H1(3,1)  0             0           H1(2,1)];
             
            b = [   F(1,3);...
                    F(2,3);...
                    F(3,3);...
                    F(1,2);...
                    F(2,2);...
                    F(3,2);...
                    F(1,1);...
                    F(2,1);...
                    F(3,1)];
             x = (A'*A)\(A'*b);% least square
             
             H2 = [  1       0   0;...
                    x(1:3)';...
                    x(4:6)'];
                
            % use Jacobian of corners to minimize distortion
            [r,c,~] = size( im1 );
            pts = [ 0 0 1;...
                    r 0 1;...
                    0 c 1;...
                    r c 1];
            H1 = minimizeDistortion( H1, pts, 0 );
            [r,c,~] = size( im2 );
            pts = [ 0 0 1;...
                    r 0 1;...
                    0 c 1;...
                    r c 1];
            H2 = minimizeDistortion( H2, pts, 0 );
            [rectIm1, rectIm2] = rectifyImages( im1, im2, H1, H2);
            
            % transform inliers
            %{
            in1 = [in1'; ones( 1,length(in1)) ];  
            in2 = [in2'; ones( 1,length(in2)) ]; 
            in1 = (H1*in1)';
            in1 = in1./repmat( in1(:,3), 1,3);
            in2 = (H2*in2)';
            in2 = in2./repmat( in2(:,3), 1,3);
            %}  
            if do_plot
                figure;
                imshow(rectIm1);
                title(' rect Image 1' );
                figure;
                imshow(rectIm2);
                title(' rect Image 2' );
            end
end

function K = minimizeDistortion( H, pts, a3 )
        
    % formulate optimization function
    f = @(a) optimizer(a,H,pts, a3);
    a0 = [ 1 1 ];
    a = fminsearch(f,a0);% Nelder-Mead simplex search
    
    A = [   a(1)    a(2)    0;...
            0       1       0;...
            0       0       1];
    K = A*H;
    
end% minimizeDistortion

function sum = optimizer(a,H,pts, a3)
    A = [   a(1)    a(2)    a3;...
            0       1       0;...
            0       0       1];
    K = A*H;
    sum = 0;
    for i=1:length(pts)
        J = homographyJacobian(K,pts(i,1:2));
        [s1,s2] = singularValues2x2(J);
        sum = sum + (s1-1)^2 + (s2-1)^2;
    end
end 

% Jacobian at a point x
function J = homographyJacobian(H, x)
   
    denom = H(3,1)*x(1) + H(3,2)*x(2) + H(3,3);
    
    % dxp/dx
    dxp_dx = H(1,1)*denom - H(3,1)*( H(1,1)*x(1) + H(1,2)*x(2) + H(1,3) );
    dxp_dx = dxp_dx/denom^2;
    % dxp/dy
    dxp_dy = H(1,2)*denom - H(3,2)*( H(1,1)*x(1) + H(1,2)*x(2) + H(1,3) );
    dxp_dy = dxp_dy/denom^2;
    %dyp/dx
    dyp_dx = H(2,1)*denom - H(3,1)*( H(2,1)*x(1) + H(2,2)*x(2) + H(2,3) );
    dyp_dx = dyp_dx/denom^2;
    %dyp/dy
    dyp_dy = H(2,2)*denom - H(3,2)*( H(2,1)*x(1) + H(2,2)*x(2) + H(2,3) );
    dyp_dy = dyp_dy/denom^2;
    
    J = [   dxp_dx  dxp_dy;...
            dyp_dx  dyp_dy];
end% homographyJacobian

function [s1,s2] = singularValues2x2(M)
    a = M(1,1); b = M(2,1); c = M(1,2); d = M(2,2);
    
    t1 = a^2+b^2+c^2+d^2;
    
    t2 = sqrt( (a^2+b^2-c^2-d^2)^2 + 4*(a*c+b*d)^2 );
    s1 = sqrt( (t1+t2)/2 );
    s2 = sqrt( (t1-t2)/2 );
end

function [im1, im2] = rectifyImages( I1, I2, H1, H2)
    % find common transformed area
    [r1,c1,~] = size(I1);
    corners1 = transformCorners( H1, r1,c1 );
    [r2,c2,~] = size(I2);
    corners2 = transformCorners( H2, r2,c2 );
    
    corners = [ corners1;corners2 ];
    x = sort( corners(:,1) );
    y = sort( corners(:,2) );
    
    xmin = ceil( x(4) );
    xmax = floor( x(5) );
    ymin = ceil( y(4) );
    ymax = floor( y(5) );
    
    width = xmax-xmin;
    height = ymax-ymin;
    
    % check dimension
    wCond = mean([c1 c2])*0.1;
    hCond = mean([r1 r2])*0.1;
    
    if width<wCond || height<hCond% new images will be <10% of originals
         %disp(strcat('Bad rectification',num2str(width),'<',num2str(wCond), ...
         %                   ' or ',num2str(height),'<',num2str(hCond)));
         %im1 = [];
         %im2 = [];
         error('recified images will be <10% of originals');

    end
    
%     xLim = [ xmin-0.5,xmax+0.5 ];
%     yLim = [ ymin-0.5,ymax+0.5 ];
%     
%     tform1 = projective2d( H1' );%% Computer Vision Toolbox function imwarp
%     tform2 = projective2d( H2' );%% Computer Vision Toolbox function imwarp
%     
%     outputView = imref2d([height-1, width-1], xLim, yLim);
%      
%     im1 = imwarp(I1, tform1, 'OutputView', outputView ); %% Computer Vision Toolbox function imwarp
%     im2 = imwarp(I2, tform2, 'Outputview', outputView );
     
     %Image Warping
     im1 = imagewarp(I1, H1);     
     im2 = imagewarp(I2, H2);
    % Bring both Images to the same size and delete the black frame
     im1=im1(ymin:ymax,xmin:xmax,:);
     im2=im2(ymin:ymax,xmin:xmax,:);



end

function corners = transformCorners( H,r,c )
    
    a = [ [1 1 1]', [c 1 1]', [c r 1]', [1 r 1]' ];   
    a = H*a;
    a = a./repmat(a(3,:),3,1);
    
    corners = [ a(1:2,1)';a(1:2,2)';a(1:2,3)';a(1:2,4)';];% start upper left CCW around
    
end


%{
        function status = rectify( obj, im1, im2 )% Mallon rectification
            obj.rectStatus = false;
            status = false;
            %% find initial rectification matrices
            obj.H1 = [   1                              0       0;...
                    -obj.epi.eP1(2)/obj.epi.eP1(1)  1       0;...
                    -1/obj.epi.eP1(1)               0       1];

            % use whole F (overconstrained) to calculate obj.H2 for less distortion
            A = [   -1             0            0       0            0            0;...
                    0              -1           0       0            0            0;...
                    0              0           -1       0            0            0;...
                    0              0            0       1            0            0;...
                    0              0            0       0            1            0;...
                    0              0            0       0            0            1;...
                    -obj.H1(3,1)   0            0       obj.H1(2,1)  0            0;...
                    0              -obj.H1(3,1) 0       0            obj.H1(2,1)  0;...
                    0               0      -obj.H1(3,1) 0            0             obj.H1(2,1)];
            b = [   obj.epi.F(1,3);...
                    obj.epi.F(2,3);...
                    obj.epi.F(3,3);...
                    obj.epi.F(1,2);...
                    obj.epi.F(2,2);...
                    obj.epi.F(3,2);...
                    obj.epi.F(1,1);...
                    obj.epi.F(2,1);...
                    obj.epi.F(3,1)];
            x = (A'*A)\(A'*b);% least square

            obj.H2 = [  1       0   0;...
                        x(1:3)';...
                        x(4:6)'];

            % use Jacobian of corners to minimize distortion
            [r,c,~] = size( im1 );
            pts = [ 0 0 1;...
                    r 0 1;...
                    0 c 1;...
                    r c 1];
            obj.H1 = minimizeDistortion( obj.H1, pts, 0 );
            [r,c,~] = size( im2 );
            pts = [ 0 0 1;...
                    r 0 1;...
                    0 c 1;...
                    r c 1];
            obj.H2 = minimizeDistortion( obj.H2, pts, 0 );

            
            [obj.rectIm1, obj.rectIm2] = rectifyImages( im1, im2, obj.H1, obj.H2 );
            
            if ~isempty( obj.rectIm1 ) && ~isempty( obj.rectIm2 )
                status = true;
                obj.rectStatus = true;
                
                % transform inliers
                obj.in1 = [obj.epi.in1'; ones( 1,length(obj.epi.in1)) ];  
                obj.in2 = [obj.epi.in2'; ones( 1,length(obj.epi.in2)) ]; 
                obj.in1 = (obj.H1*obj.in1)';
                obj.in1 = obj.in1./repmat( obj.in1(:,3), 1,3);
                obj.in2 = (obj.H2*obj.in2)';
                obj.in2 = obj.in2./repmat( obj.in2(:,3), 1,3);
                
            end
        end% rectify
%}   




