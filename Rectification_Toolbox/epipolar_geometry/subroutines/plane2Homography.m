% planeHomography - calculates the homography induced by a 3D plane
% from 3 point correspndances ( given as 2 3*3 matrices 1 point per row )
% and the fundamental matrix. 4 arg is optinal if the epipole of image 2 is
% pre calculated.
function H = plane2Homography( v1, v2, F, eP2 )

    if nargin<4% calc epipole
        eP2 = null(F');
        eP2 = eP2./eP2(3);
    end
    
    A = Skew( eP2 )*F;
    b = zeros( 3,1 );
    
    for i=1:3
        b(i) = cross( v2(i,:)', A*v1(i,:)' )'*cross( v2(i,:)', eP2 );
        b(i) = b(i)/norm( cross(v2(i,:)',eP2 ) )^2;
    end
    M = [ v1(1,:);v1(2,:);v1(3,:) ];

    H = A-eP2*( M\b )';% 13.6 H/Z, p.331
    
end% planeHomography
