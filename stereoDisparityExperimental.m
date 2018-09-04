function DispMap=stereoDisparityExperimental(left, right,halfBlockSize, disparityRange, do_plot)

% The disparity range defines how many pixels away from the block's location

fprintf('Performing basic block matching...\n');

% Start a timer.
tic();

% DispMap will hold the result of the block matching. 
% The values will be 'single' precision (32-bit) floating point.
DispMap = zeros(size(left), 'single');

% Define the size of the blocks for block matching.
blockSize = 2 * halfBlockSize + 1;

% Get the image dimensions.
[imgHeight, imgWidth, ~] = size(left);

heightFrom = round(imgHeight*9/20);
heightTill = round(imgHeight*11/20);
widthFrom = round(imgWidth*9/20);
widthTill = round(imgWidth*11/20);

% For each row 'm' of pixels in the image...
for m = heightFrom : heightTill
    	
	% Set min/max row bounds for the template and blocks.
	% e.g., for the first row, minr = 1 and maxr = 4
    minr = max(1, m - halfBlockSize);
    maxr = min(imgHeight, m + halfBlockSize);
    
%     minj = max(-10, 1-minr);
%     maxj = min(10, imgHeight-maxr);
	
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
		%
		% In the "Cones" dataset, we only need to search to the right, so mind
		% is 0.
		%
		% For other images which require searching in both directions, set mind
		% as follows:
        mind = max(-disparityRange, 1 - minc);
		%mind = 0; 
        maxd = min(disparityRange, imgWidth - maxc);

		% Select the block from the right image to use as the template.
        template = right(minr:maxr, minc:maxc,:);
		
		% Get the number of blocks in this search.
		numBlocks = maxd - mind + 1;
		
		% Create a vector to hold the block differences.
		blockDiffs = zeros(numBlocks, 1);
		colorOK = 0;
		% Calculate the difference between the template and each of the blocks.
        for i = mind : maxd
            for j = 0 : 0

%                 reddiff= double(right(m,n, 1))-double(left(m+j,n+i,1));
%                 greendiff = double(right(m,n, 2))-double(left(m+j,n+i,2));
%                 bluediff = double(right(m,n, 3))-double(left(m+j,n+i,3));
%                 
%                 colordiff = (reddiff)^2 + (greendiff)^2 + (bluediff)^2;
%                 
%                 if colordiff > 300
%                     continue;
%                 end
%                 
%                 colorOK = colorOK +1;
                
                % Select the block from the left image at the distance 'i'.
                block = left((minr+j):(maxr+j), (minc + i):(maxc + i),:);

                
                
                % Compute the 1-based index of this block into the 'blockDiffs' vector.
                blockIndex = i - mind + 1;

                % Take the sum of absolute differences (SAD) between the template
                % and the block and store the resulting value.
			blockDiffs(blockIndex, 1) = sum(sum(sum((template - block).^2)));
            end
        end
%         disp(colorOK);
%         
%         if(colorOK == 0)
%             disp('problem');
%             disp(right(m,n,:));
%         end
        
		% Sort the SAD values to find the closest match (smallest difference).
		% Discard the sorted vector (the "~" notation), we just want the list
		% of indices.
		
		DispMap(m, n) = min(blockDiffs);
    end
    
    
    % Update progress every 10th row.
    eta = toc()/(m-heightFrom)*(heightTill-m);
    clc;
    fprintf('  ETA %.2f min', eta / 60.0);
		
end

% Display compute time.
elapsed = toc();
fprintf('Calculating disparity map took %.2f min.\n', elapsed / 60.0);

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
