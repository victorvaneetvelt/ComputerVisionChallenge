% gets a 2D transformation and a [r,c] size and returns a transformed
% bounding box (4*2)
function box = boundingBox( T, orgSize )
    
    p(1,:) = [1,1,1];
    p(2,:) = [orgSize(2),1,1];
    p(3,:) = [orgSize(2),orgSize(1),1];
    p(4,:) = [1,orgSize(1),1];
    
    corners = zeros(4,3);
    for i=1:4
        corners(i,:) = (T*p(i,:)')'; corners(i,:) = corners(i,:)/corners(i,3);
    end
    
    box = corners(:,1:2);
end
   