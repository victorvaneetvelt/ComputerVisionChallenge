%% Epipolar - a base class for holding the epipolar geometric information shared by two images. 
%
% %%%%%%%%%%%%%%%%%%METHODS%%%%%%%%%%%%%%%%%%%%%%
% Epipolar( im1, im2, P1, P2 )		- Constructor, estimates the fundamental matrix
% and other epipolar properties, optional camera matrix arguments.
% plotEpiLine(option, n)		- Plots n epipolar line of image <1 or 2>
% plotEpiPole(option)		- Plots the epipole of image <1 or 2>
% plotInlierFeatures(option, n)	- Plots n inliers of image <1 or 2> 
% triangulate( optimal )    - triagulate for a projective reconstruction,
% optional 'optimal' arg for better accuracy (computationally expensive)
% triangulateAffine( v1,v2 ) - does a affine 3D reconstruction based on 3 point correspndances at infinity.
% correctInliers( obj ) - fixes inliers points to the nearest epipolar line
% 
% 
% %%%%%%%%%%%%%%%%%%PROPERTIES%%%%%%%%%%%%%%%%%%%%%%
% 
%         im1%    image 1
%         im2%    image 2
%         
%         F%      estimated fundamental matrix
%         
%         eP1%    epipole of image 1 (image of camera center 2)
%         eP2%    epipole 2          (image of camera center 1)
%         eL1%    epipolar line 1    (lines in image 1 due to points in 2)
%         eL2%    epipolar line 2    (lines in image 2 due to points in 1) 
%         
%         in1%    inliers of corresponding points in image 1 
%         in2%    inliers of corresponding points in image 2
        

%% class definition

classdef Epipolar < handle
    
    %% Properties
    properties
        im1%    image 1
        im2%    image 2
        
        F%      estimated fundamental matrix
        
        eP1%    epipole of image 1 (image of camera center 2)
        eP2%    epipole 2          (image of camera center 1)
        eL1%    epipolar line 1    (lines in image 1 due to points in 2)
        eL2%    epipolar line 2    (lines in image 2 due to points in 1) 
        
        in1%    inliers of corresponding points in image 1 
        in2%    inliers of corresponding points in image 2
        
        worldPts%   results of triangulation
        P1%     camera matrix 1, will be canonical if not specified
        P2%     camera matrix 2, will be caononical if not specified
        
    end% properties
    
    
    %% methods
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = Epipolar( im1, im2, P1, P2 )% Constructor
            obj.im1 = im1;
            obj.im2 = im2;
            
            % estimate the fundamental matrix 
            [obj.F,obj.in1, obj.in2] = extractF(im1,im2);
            
            % calculate epipolar lines
            calcEpiLines(obj);
            
            % calculate epipoles
            calcEpipoles(obj);
            
            % set/construct camera matrices
            if nargin == 4
                obj.P1 = P1;
                obj.P2 = P2;
            else
                % Let cameras be canonical, Hartley/Zisserman p.256
                obj.P1 = [eye(3),[  0   0   1   ]'];
                eP2 = obj.eP2./norm( obj.eP2 );
                obj.P2 = [ Skew(eP2)*obj.F, eP2];
            end

        end% Epipolar constructor
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function calcEpiLines( obj )
            % calculate epipolar lines
            % of image 1 due to points in image 2
            obj.eL1 = epipolarLine( obj.F', obj.in2(:,1:2) );
            % of image 2 due to points in image 1
            obj.eL2 = epipolarLine( obj.F, obj.in1(:,1:2) );
        end% calcEpiLines
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function calcEpipoles( obj )
            % calculate epipoles
            % of image 1 due to camera center in image 2 (right nullspace)
            obj.eP1 = null(obj.F);
            obj.eP1 = obj.eP1./obj.eP1(3);
            % of image 2 due to camera center in image 1 (left nullspace)
            obj.eP2 = null(obj.F');
            obj.eP2 = obj.eP2./obj.eP2(3);
        end% calcEpipoles
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function plotEpiLine( obj, imOption, nr )
            
            if nargin<=2
                nr = length( obj.eL1 );
            elseif nr>length( obj.eL1 )
                error('Too many lines requested\n');
            end
             
            switch imOption
                case 1
                    plottablePts1 = lineToBorderPoints( obj.eL1(1:nr,:), size( obj.im1 ) );
                    line( plottablePts1( :,[1,3] )', plottablePts1(:,[2,4])', 'Color','cyan');
                case 2
                    plottablePts2 = lineToBorderPoints( obj.eL2(1:nr,:), size( obj.im2 ) );
                    line( plottablePts2( :,[1,3] )', plottablePts2(:,[2,4])', 'Color','cyan');
                otherwise
                    error('Not a valid option\n');
            end
        end% plotEpiLines
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function plotEpiPole( obj, imOption )
            switch imOption
                case 1
                    plot( obj.eP1(1), obj.eP1(2), 'gs' );
                case 2
                    plot( obj.eP2(1), obj.eP2(2), 'gs' );
                otherwise
                    error('Not a valid option\n');
            end
        end% plotEpiPole
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function plotInlierFeatures( obj, imOption, nr )
            
            if nargin<=2
                nr = length( obj.in1 );
            elseif nr>length( obj.in1 )
                error('Too many points requested\n');
            end
            
            switch imOption
                case 1
                    plot( obj.in1(1:nr,1), obj.in1(1:nr,2),'go' );
                    plot( obj.in1(1:nr,1), obj.in1(1:nr,2),'g+' );
                case 2
                    plot( obj.in2(1:nr,1), obj.in2(1:nr,2),'go' );
                    plot( obj.in2(1:nr,1), obj.in2(1:nr,2),'g+' );
                otherwise
                    warning('Not a valid option\n');
            end
                    
        end% plotInlierFeatures
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function worldPts = triangulate( obj, optimal )
            if nargin==2 && strcmp(optimal,'optimal')
                worldPts = triangulate2d(obj.in1, obj.in2,obj.P1,obj.P2,obj.F);
            else
                worldPts = triangulate2d(obj.in1, obj.in2,obj.P1,obj.P2); 
            end
            obj.worldPts = worldPts;
        end% triangulate
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function worldPts = triangulateAffine( obj, v1,v2 )
            % find the infinite homography
            A = Skew( obj.eP2 )*obj.F;
            b = zeros( 3,1 );
            for i=1:3
                b(i) = cross( v2(i,:)', A*v1(i,:)' )'*cross( v2(i,:)', obj.eP2 );
                b(i) = b(i)/norm( cross(v2(i,:)',obj.eP2 ) )^2;
            end
            M = [ v1(1,:);v1(2,:);v1(3,:) ];
            
            H = A-obj.eP2*( M\b )';% 13.6 H/Z, p.331
            
            tmp = obj.P2(1:3,1:3);
            obj.P2(1:3,1:3) = H;% H/Z, p339
            
            worldPts = obj.triangulate('optimal');
            obj.P2(1:3,1:3) = tmp;
            
        end% triangulateAffine
        
        function correctInliers( obj )
            len = length( obj.in1 );
            obj.in1 = [ obj.in1(:,1:2), ones(len, 1) ];
            obj.in2 = [ obj.in2(:,1:2), ones(len, 1) ];
            
            for i=1:len
                [obj.in1(i,:),obj.in2(i,:)] = correctedCorrespondance( obj.in1(i,:), obj.in2(i,:), obj.F );
            end
        end% correctInliers

        
    end% methods
    
    
end% Epipolar