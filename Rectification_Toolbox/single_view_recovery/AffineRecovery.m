%% affine recovery class
% A child of the recovery class, uses a line at infinity (from 2 and 2 pre-projected, parallel lines) to recover affine properties.
% Usage:
%         - getPointsAtInfinity()
%         - getTransformation()
%         - getRecoveredCorners()

        
%% class definition

classdef AffineRecovery < Recovery
        
    %% properties
    properties (SetAccess = private)
        ptsAtInf
        Ha
        recoveredCorners
    end% properties
    
    %% methods
    methods
        
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         function obj = AffineRecovery( filename )
%             if  nargin == 1
%                 setImage(filename);
%             end
%         end% AffineRecovery constructor
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function recover(obj)
            
            
            % Parallel L1&L3 intersect at xi1, Parallel L2&L4 intersect at xi2
            L1 = cross( obj.corners(1,:)', obj.corners(2,:)' );
            L2 = cross( obj.corners(2,:)', obj.corners(3,:)' ); 
            L3 = cross( obj.corners(4,:)', obj.corners(3,:)'); 
            L4 = cross( obj.corners(1,:)', obj.corners(4,:)'); 
            xi1 = cross(L1,L3);
            xi1 = xi1/xi1(3);% point at infinity
            xi2 = cross(L2,L4);
            xi2 = xi2/xi2(3);% point at infinity
            
            obj.ptsAtInf(1,:) = xi1';
            obj.ptsAtInf(2,:) = xi2';
            
            % line at infinity
            Li = cross(xi1,xi2);
            Li = Li/Li(3);

            % The homographic transform recovering the affine properties
            obj.Ha = [  1   0   0;...
                        0   1   0;...
                        Li'];
            
                    
            if  ( any(isnan( obj.Ha(:) ))  || outOfBounds(obj.Ha,size(obj.image),8000) )
                disp('No valid affine transformation')
                return;
            end
            
            %tform = affine2d( obj.Ha );
            tform = projective2d( obj.Ha' );
            
            
            % apply transformation
            if obj.imageOpened
                obj.recoveredImage = imwarp( obj.image, tform );
                obj.recovered = true;
                
            else
                notify(obj,'noImage');
            end

        end% recovery
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function pts = getPointsAtInfinity(obj)
            pts = obj.ptsAtInf;
        end% getPointsAtInfinity
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function T = getTransformation(obj)
            T = obj.Ha;
        end% getTransformation
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function corners = getRecoveredCorners(obj)
            corners = zeros(4,3);
            p = obj.getCorners();
            for i = 1:4
                corners(i,:) = ( obj.Ha*p(i,:)' )';
                corners(i,:) = corners(i,:)/corners(i,3);
            end% for
        end% getRecoveredCorners
        
    end% methods
end% AffineRecovery

