
im1 = imread( 'rectifiedImage1_1.png' );
im2 = imread( 'rectifiedImage2_1.png' );
load( 'disparityValues_1.mat' );% disparityMap, disparityRange
% figure,imshow(im1);


%% segment object from background
objectIm = disparityMap;
objectIm( disparityMap<(disparityRange(2)/2)*1.3 ) = 0;% background

gs = rgb2gray(im1);
segIm = gs;
segIm( (objectIm==0) ) = 0;% pick only out pixels inside disparity object
% find intensity threshold (Otsu's method) and convert to binary image
thres = graythresh(gs);
bw = imbinarize( segIm, thres);
% figure, imshow(bw),title('Binary Otsu');

segIm( bw ) = 0;% based on intensity since ground plane is white
objectIm( bw ) = 0;


% figure, imshow( objectIm, disparityRange );
% figure,imshow(segIm);
%% show results
idx = zeros(size(im1,1), size(im1,2), 3,'logical');
idx(:,:,1) = objectIm==0;
idx(:,:,2) = objectIm==0;
idx(:,:,3) = objectIm==0;
rgb = im1;
rgb( idx ) = 0;
figure,subplot(2,3,1);
imshow(im1);
title('Original');
subplot(2,3,2);
imshow( disparityMap,disparityRange );
title('Disparity');

comp = imfuse( im1, rgb  );
subplot(2,3,3);
imshow(comp);
title('Segmentation');

total = size(im1,1)*size(im1,2);
i = objectIm>0;
objectSize = sum( i(:) );

fprintf(    'Total nr of pixels: %d\nNr of object pixels: %d\nReduction: %.2f\n',...
            total, objectSize, (1-objectSize/total) );

%% get correlating points of object
[Y,X] = find( objectIm>0 );

len = length(X);
in1 = [ X, Y, ones(len,1) ];
in2 = in1;
obj = objectIm>0;
in2(:,1) = in2(:,1) - disparityMap( obj );
rho = 1e3;% scale
z = 1./disparityMap(obj);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% point cloud 
r = reshape(rgb(:,:,1),[],1);
g = reshape(rgb(:,:,2),[],1);
b = reshape(rgb(:,:,3),[],1);
r( r==0 ) = [];
g( g==0 ) = [];
b( b==0 ) = [];
color = [ r, g, b ]; 

pts = [ in1(:,1).*z, in1(:,2).*z, z*rho ];

ptCloud = pointCloud( pts, 'Color',color );
subplot(2,3,[4 5 6] );
pcshow(ptCloud);
title('Point cloud');

% % filter
% ptCloud = pcdenoise( ptCloud );
% 
% % find normals
% normals = pcnormals( ptCloud,15 );
% %display normals
% x = ptCloud.Location(1:100:end,1);
% y = ptCloud.Location(1:100:end,2);
% z = ptCloud.Location(1:100:end,3);
% u = normals(1:100:end,1);
% v = normals(1:100:end,2);
% w = normals(1:100:end,3);
% 
% hold on
% quiver3(x,y,z,u,v,w);
% hold off

