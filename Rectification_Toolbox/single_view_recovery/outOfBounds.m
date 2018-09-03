% performs a transformation (H) on a bounding box and compares the result
% to a given max limit, returns true if transformed corners are greater
% than lim.
function a = outOfBounds(H, boxSize, lim)

    p(1,:) = [0,0,1];
    p(2,:) = [boxSize(2),0,1];
    p(3,:) = [boxSize(2),boxSize(1),1];
    p(4,:) = [0,boxSize(1),1];
    
    corners = zeros(4,3);
    for i=1:4
        corners(i,:) = H*p(i,:)'; corners(i,:) = corners(i,:)/corners(i,3);
    end
    
    a = max( abs(corners(:)) )>8000;
    a = logical( a(:) );
end% outOfBounds