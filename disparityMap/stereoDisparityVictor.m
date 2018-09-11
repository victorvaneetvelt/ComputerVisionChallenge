function DispMap=stereoDisparityVictor(left, right,halfBlockSize, disparityRange, do_plot)

fprintf('Performing basic block matching...\n');

% Get the image dimensions.
[imgHeight, imgWidth, ~] = size(left);

% DispMap will hold the result of the block matching. 
DispMap = zeros(imgHeight, imgWidth, 'single');

% Define the size of the blocks for block matching.
blockSize = 2 * halfBlockSize + 1;

heightFrom = round(imgHeight*5/20);
heightTill = round(imgHeight*15/20);
widthFrom = round(imgWidth*8/20);
widthTill = round(imgWidth*12/20);
%  heightFrom = 1;
%  heightTill = imgHeight;
%  widthFrom = 1;
%  widthTill = imgWidth;
 
% For each row 'm' of pixels in the image...
for m = heightFrom : heightTill
    
	% Set min/max row bounds for the template and blocks.
	% e.g., for the first row, minr = 1 and maxr = 4
    minr = max(1, m - halfBlockSize);
    maxr = min(imgHeight, m + halfBlockSize);
	
    % For each column 'n' of pixels in the image...
    for n = widthFrom : widthTill
        
		% Set the min/max column bounds for the template.
		% e.g., for the first column, minc = 1 and maxc = 4
		minc = max(1, n - halfBlockSize);
        maxc = min(imgWidth, n + halfBlockSize);
        
		% Define the search boundaries as offsets from the template location.
		% Limit the search so that we don't go outside of the image. 
		% 'mind' is the the maximum number of pixels we can search to the left.
		% 'maxd' is the maximum number of pixels we can search to the right.
        mind = max(-disparityRange, 1 - minc);
        maxd = min(disparityRange, imgWidth - maxc);
        

		% Select the block from the right image to use as the template.
        template = right(minr:maxr, minc:maxc, :);
		
        block = left(minr:maxr, (minc):(maxc), :);
        bestBlockDiff = sum(sum(sum((template - block).^2)));
        distance = 0;
        
		% Bestimmen des Mittelpunktes des Fensters(block)
        for i = mind : maxd
        
			% Select the block from the left image at the distance 'i'.
			block = left(minr:maxr, (minc + i):(maxc + i), :);
            blockDiff = sum(sum(sum((template - block).^2)));
            if blockDiff < bestBlockDiff
                bestBlockDiff = blockDiff;
                distance = i;
            end
        end
		DispMap(m, n) = distance; 
    end
	
    eta = toc()/(m-heightFrom)*(heightTill-m);
    clc;
    fprintf('  ETA %.0fmin %.0fsec', eta / 60.0, mod(eta,60));
		
end

% Display compute time.
% elapsed = toc();
% fprintf('Calculating disparity map took %.2f min.\n', elapsed / 60.0);

% =========================================
%        Visualize Disparity Map
% =========================================
if do_plot==true
fprintf('Displaying disparity map...\n');


% Switch to figure 1.
figure(1);

% Clear the current figure window.
clf;

% Display the disparity map. 
% Passing an empty matrix as the second argument tells imshow to take the
% minimum and maximum values of the data and map the data range to the 
% display colors.
imagesc(DispMap);

% Configure the axes to properly display an image.
axis image;

% Use the 'jet' color map.
% You might also consider removing this line to view the disparity map in
% grayscale.
colormap('jet');

% Display the color map legend.
colorbar;

% Specify the minimum and maximum values in the disparity map so that the 
% values can be properly mapped into the full range of colors.
% If you have negative disparity values, this will clip them to 0.
%caxis([0 disparityRange]);

% Set the title to display.
title(strcat('Basic block matching, Sub-px acc., Search right, Block size = ', num2str(blockSize)));
end
end

