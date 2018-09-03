% Triangulate corresponding points (n*3) with the camera matrices to retreive depth.
% There is a triangulate in the MATLAB toolbox but it does not normalize
% the data. This function also adds the alternative to shift point correspondances to fit
% with the fundamental matrix if F is given as the optional argument. This
% may be neccessary when using measurements that are prone to error.
function pts = triangulate2d( x, xp, Px, Pxp, F )

    % validate input
    [r,c] = size(x);
    
    if c<3% make homogeneous
        x = [x,ones(r,1)];
        xp = [xp,ones(r,1)];
    end
    
    if nargin==5
        for i=1:r
%             xp(i,:)*F*x(i,:)'
            
%                 fprintf('Index: %.2f\n',i);
%                 fprintf('x: (%.2f, %.2f, %.2f), xp: (%.2f, %.2f, %.2f)\n',...
%                         x(i,1),x(i,2),x(i,3),xp(i,1),xp(i,2),xp(i,3));
%             
            [x(i,:), xp(i,:)] = correctedCorrespondance(x(i,:),xp(i,:),F);
%             xp(i,:)*F*x(i,:)' 
             
%                 fprintf('x: (%.2f, %.2f, %.2f), xp: (%.2f, %.2f, %.2f)\n',...
%                         x(i,1),x(i,2),x(i,3),xp(i,1),xp(i,2),xp(i,3));
            
        end
    end
    

    % normalize
    if r>1
        [ x, Tx ] = normalize( x );
        [ xp, Txp ] = normalize( xp );
    else
        Tx = eye(3);
        Txp = Tx;
    end

    Px = Tx*Px;
    Pxp = Txp*Pxp;
    
    pts = zeros( r, 3 );
    
    for i=1:r
        
        A = [   x(i,1)*Px(3,:)-Px(1,:);...
                x(i,2)*Px(3,:)-Px(2,:);...
                xp(i,1)*Pxp(3,:)-Pxp(1,:);...
                xp(i,2)*Pxp(3,:)-Pxp(2,:)];
        [~,~,V] = svd( A );
        pt = V(:,end);
        pt = pt./pt(end);
        
        pts(i,:) = pt(1:3);
    end
  
end% triangulate2d

