% minimizeDistortion: Given a rectification homography and some
% cornerpoints the optimal values for H(1,1) and H(1,2) are found to
% minimize distortion.
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


function [s1,s2] = singularValues2x2(M)
    a = M(1,1); b = M(2,1); c = M(1,2); d = M(2,2);
    
    t1 = a^2+b^2+c^2+d^2;
    
    t2 = sqrt( (a^2+b^2-c^2-d^2)^2 + 4*(a*c+b*d)^2 );
    s1 = sqrt( (t1+t2)/2 );
    s2 = sqrt( (t1-t2)/2 );
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
    
    
    
