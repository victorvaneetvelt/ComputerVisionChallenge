% noisy points have to be put on the epipolar lines, H/Z algorithm 12.1,
% p.318
function [x,xp] = correctedCorrespondance( initialx, initialxp, F )

    %% translate to origin
    Tinv = eye(3); Tinv(1,3)=initialx(1); Tinv(2,3)=initialx(2);
    Tpinv = eye(3); Tpinv(1,3)=initialxp(1); Tpinv(2,3)=initialxp(2);

    F = Tpinv'*F*Tinv;% new corresponding F

    % compute new normlized epipoles
    e = null(F);
    
    if isempty(e)
        error('Bad fundamental matrix, try a better estimate/image\n');
    end
    e = e./norm( e(1:2) );
    ep = null(F'); ep = ep./norm( ep(1:2) );
    
    %% rotate by epipoles
    R = [   e(1)    e(2)    0;...
            -e(2)   e(1)    0;...
            0       0       1];
    Rp = [   ep(1)   ep(2)  0;...
            -ep(2)   ep(1)  0;...
            0       0       1];
        
    F = Rp*F*R';
   
    %% solve polynomial related to sum of total squared distance to epipolar line
    f = e(3); fp = ep(3); a = F(2,2); b = F(2,3); c = F(3,2); d = F(3,3);
    p = minPolynomial( a,b,c,d,f,fp );
    t = roots( p );
    t = real(t);% real part of roots
    s = zeros(length(t),1);
    for i=1:length(t)
        s(i) = t(i)^2/(1+f^2*t(i)^2)+...
               (c*t(i)+d)^2/( (a*t(i)+b)^2+fp^2*(c*t(i)+d)^2 );
    end
    
    sinf = 1/f^2 + c^2/(a^2+fp^2*c^2);% asymptotic value 
    [smin,tmin] = min(s);% find minimized s
    tmin = t(tmin);% t responsible for minimized s
    
    %% evaluate lines of tmin and find the closest points to the origin
    if sinf<smin
        error('Asymptotic is minima, what to do??')
    end
    l = [tmin*f;1;-tmin];
    lp = [ -fp*(c*tmin+d); a*tmin+b; c*tmin+d ];
    
    x = [-l(1)*l(3), -l(2)*l(3), l(1)^2+l(2)^2 ];
    xp = [-lp(1)*lp(3), -lp(2)*lp(3), lp(1)^2+lp(2)^2 ];
    
    %% transfer the points to original basis
    x = ( Tinv*R'*x' )';
    xp =( Tpinv*Rp'*xp' )';

    x = x./x(end);
    xp = xp./xp(end);
    
  
end% correctedCorrespondance

function p = minPolynomial( a, b, c, d, f, fp )% helper
    syms t
    p = collect(   t*((a*t+b)^2+fp^2*(c*t+d)^2)^2 - ...
        (a*d-b*c)*(1+f^2*t^2)^2*(a*t+b)*(c*t+d),t );
    p = coeffs(p,t,'All');
end
