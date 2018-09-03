%% Metric recovery class
% A child of the recovery class, using 5 orthogonal lines to recover mertric properties.
% Usage:
%         - TBD

%% class definition


classdef MetricRecovery < Recovery
    
    %% properties
    properties (SetAccess = private)
        HpInv
    end% properties
    
    %% methods
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function recover(obj)
            
            % corners of the rectangle have lines L1 perp L2, L3 perp L4
            L1 = cross( obj.corners(1,:)', obj.corners(2,:)' );
            L2 = cross( obj.corners(2,:)', obj.corners(3,:)' ); 
            L3 = cross( obj.corners(4,:)', obj.corners(3,:)'); 
            L4 = cross( obj.corners(1,:)', obj.corners(4,:)');
            
            % last pair of perpendicular lines we ASSUME a square
            L5 = cross( obj.corners(1,:)',obj.corners(3,:)' );
            L6 = cross( obj.corners(2,:)',obj.corners(4,:)' );

  
            
            % The A matrix gathering all the normal lines
            A = zeros(5,6);
            A(1,:) = Lines2Ai(L1,L2);
            A(2,:) = Lines2Ai(L2,L3);           
            A(3,:) = Lines2Ai(L3,L4);
            A(4,:) = Lines2Ai(L4,L1);
            A(5,:) = Lines2Ai(L5,L6);

            [~, ~, V] = svd(A);

            c = V(:,6);

            C = [   c(1),  c(2)/2, c(4)/2;...
                    c(2)/2,  c(3), c(5)/2;...
                    c(4)/2,  c(5)/2, c(6)];
            
            [U, Sigma, ~] = svd(C);

            Hp = [U(:,1)*sqrt(Sigma(1,1)), U(:,2)*sqrt(Sigma(2,2)), U(:,3)/U(3,3)];
            
            try
                obj.HpInv = inv(Hp);
            catch
                disp('Singularity');
                return;
            end
            
            if  ( any(isnan( obj.HpInv(:) )) || outOfBounds(obj.HpInv,size(obj.image),8000) )
                disp('No valid projective transformation')
                return;
            end
  
            tform = projective2d( obj.HpInv' );
           
            
            % apply transformation
            if obj.imageOpened
                obj.recoveredImage = imwarp( obj.image, tform );
                obj.recovered = true;
            else
                notify(obj,'noImage');
            end
            
        end% recover
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function T = getTransformation(obj)
            T = obj.HpInv;
        end% getTransformation
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function corners = getRecoveredCorners(obj)
            corners = zeros(4,3);
            p = obj.getCorners();
       
            for i = 1:4
                corners(i,:) = ( obj.HpInv*p(i,:)' )';
                corners(i,:) = corners(i,:)/corners(i,3);
            end% for
        end% getRecoveredCorners
    
    end% methods
    
    
end% MetricRecovery


function Ai = Lines2Ai(L,M)
% This function calculates the coefficient row Ai when
% L'*C*M is converted to Ai*c where C = [a b/2 d/2;b/2 c e/2;d/2 e/2 f]
% and c =[a b c d e f]'
Ai = [L(1)*M(1) 0.5*(L(1)*M(2) + L(2)*M(1)) L(2)*M(2) ...
        0.5*(L(1)*M(3) + L(3)*M(1)) ...
        0.5*(L(2)*M(3) + L(3)*M(2)) L(3)*M(3)];
end

