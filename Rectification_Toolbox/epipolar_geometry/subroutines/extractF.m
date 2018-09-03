% Performs image processing to estimate the fundamental matrix.
% Returns the fundamental matrix and the inliers found.
function [F,pts1,pts2] = extractF( im1, im2 )

im1 = rgb2gray( im1 );
im2 = rgb2gray( im2 );

% filter out noise
im1 = imgaussfilt( im1, 1 );
im2 = imgaussfilt( im2, 1 );

% %% detect corresponding features
pt1 = detectSURFFeatures( im1 );
pt2 = detectSURFFeatures( im2 );

% pt1 = detectHarrisFeatures( im1 );
% pt2 = detectHarrisFeatures( im2 );

[ft1, validPt1] = extractFeatures( im1, pt1 );
[ft2, validPt2] = extractFeatures( im2, pt2 );

sharedIndex = matchFeatures( ft1, ft2 );

mtchPt1 = validPt1( sharedIndex(:,1), : );
mtchPt2 = validPt2( sharedIndex(:,2), : );


%% estimate fundamental matrix 
[ F, inlierIndex ] = estimateFundamentalMatrix( mtchPt1, mtchPt2,...
                'Method','RANSAC','NumTrials',10000,'DistanceThreshold',1e-2 );
pts1 = mtchPt1( inlierIndex ).Location;
pts2 = mtchPt2( inlierIndex ).Location;

%showMatchedFeatures(im1, im2, mtchPt1(inlierIndex),mtchPt2(inlierIndex),'montage','PlotOptions',{'ro','go','y--'});


end
