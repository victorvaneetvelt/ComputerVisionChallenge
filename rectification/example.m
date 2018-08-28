%example.m
%
%   An example showing rectification of two given images so that their horizontal
%   scanlines correspond. The function to call is
%		 rectify_images
%   The example here shows how the input should be prepared for calling the function
%   and how the output can be displayed.
%
%Du Huynh, September 2003.
%
%Copyright Du Huynh
%The University of Western Australia
%   School of Computer Science and Software Engineering

imfile1 = 'calib1.jpg';
im1 = imread(imfile1);
imfile2 = 'calib2.jpg';
im2 = imread(imfile2);

% imagetype = grey or coloured
if size(im1,3) == 1
   imagetype = 'g';
else
   imagetype = 'c';
end

% load the pre-identified matching feature points (in practice, these matching
% feature point coordinates would be automatically computed by a robust
% feature tracker or matcher)
datfile1 = 'calib1.dat';
xx1 = load(datfile1);
datfile2 = 'calib2.dat';
xx2 = load(datfile2);

% Notes:
% (1) xx1 and xx2 should both be of size n-by-2 matrices, with one image point per row.
%     Here n is the number of corresponding points and, for the estimation of the
%     fundamental matrix, n >= 7.  In the code for rectification, we follow the
%     convention that each column contains an image point in homogeneous coordinates.
% (2) xx1 and xx2 should be in x-y coordinates, with the origin of the image coordinate
%     system at the top-left corner and y-axis pointing down.  For the computation
%     that follows, we need to convert the image coordinate system to be origined
%     at the centre of the image buffer with the y-axis pointing down.

% number of matching points
no_matches = size(xx1,1);

% operations for note (1) above
x1 = [xx1 ones(size(xx1,1), 1)]';
x2 = [xx2 ones(size(xx2,1), 1)]';
% operations for note (2) above
siz = size(im1);
origin = [siz(2); siz(1)]/2;

axis_x = -origin(1) : (origin(1)-1);
axis_y = (origin(2)-1) : -1 : -origin(2);

% T is the 3-by-3 transformation matrix required for operation (2) above
T = [1 0 -origin(1); 0 -1 origin(2); 0 0 1];
x1 = T*x1;
x2 = T*x2;

% call the simple linear method for computing the fundamental matrix.  This
% is an example on rectification.  Strictly speaking, the non-linear method
% for estimating the fundamental matrix should be employed here.
% [F,errs] = fundmatrix_ls([x1; x2], [], []);

% try replacing the line above with:
opt = lmeds_options('func', 'fundmatrix_nonlin', 'prop_outliers', 0.2, 'inlier_noise_level', 1);
[F,inl,outl,errs,avgerr] = lmeds([x1;x2], opt);

% finally, rectify the two images
[newim1, newim2, box, H1, H2] = rectify_images(im1, im2, x1, x2, F);

minx = box(1); miny = box(2);
maxx = box(3); maxy = box(4);

% points corresponding to x1 and x2 in the new images are H1*x1 and H2*x2.
newx1 = pflat(H1*x1);
newx2 = pflat(H2*x2);

% -----
% plot the input images
figure(1),
imagesc(axis_x, axis_y, im1), axis xy, axis on, hold on
plot(x1(1,:), x1(2,:), 'g*')
text(x1(1,:), x1(2,:), num2str( (1:no_matches)' ));
title('First original image');
if imagetype == 'g', colormap gray; end

figure(2),
imagesc(axis_x, axis_y, im2), axis xy, axis on, hold on
plot(x2(1,:), x2(2,:), 'g*')
text(x2(1,:), x2(2,:), num2str( (1:no_matches)' ));
title('Second original image');
if imagetype == 'g', colormap gray; end

% plot the outputs
figure(3),
imagesc(minx:maxx, maxy:-1:miny, newim1), axis xy, axis on, hold on
line([minx; maxx]*ones(1,no_matches), [newx1(2,:); newx1(2,:)]);
plot(newx1(1,:), newx1(2,:), 'g*')
axis equal
title('First rectified image');
if imagetype == 'g', colormap gray; end

figure(4),
imagesc(minx:maxx, maxy:-1:miny, newim2), axis xy, axis on, hold on
line([minx; maxx]*ones(1,no_matches), [newx2(2,:); newx2(2,:)]);
plot(newx2(1,:), newx2(2,:), 'g*')
axis equal
title('Second rectified image');
if imagetype == 'g', colormap gray; end

