% similarity transform points to give them a new center in (0,0) and an
% average distance of sqrt(2) to the origin. 
function [newPts, T] = normalize(pts)
    
    % find centroid of points
    centroid = mean( pts(:,1:2) );
    % and translate
    generatorPts(:,1) = pts(:,1) - centroid(1);
    generatorPts(:,2) = pts(:,2) - centroid(2);
    % find current average distance
    dist = sqrt( generatorPts(:,1).^2 + generatorPts(:,2).^2 );
    meanDist = mean( dist(:) );
    % and find scale with it
    scale = sqrt(2)/meanDist;
    
    % make transform
    T = [   scale   0       -scale*centroid(1);...
            0       scale   -scale*centroid(2);...
            0       0       1];
    % and apply
    newPts = (T*pts')';
    
    
end% normalize