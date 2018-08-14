function DispMap=stereoDisparity(F,left, right,halfBlockSize, disparityRange, do_plot)

% The following code was adapted from a Mathworks example available here:
% http://www.mathworks.com/help/vision/examples/stereo-vision.html
%
% This script will compute the disparity map for the image 'right.png' by
% correlating it to 'left.png' using basic block matching and sub-pixel
% estimation. This code corresponds to sections 1 - 3 of the Mathworks 
% tutorial. 
%
% The main differences with the original tutorial are the following:
%   - Removed dependency on the TemplateMatcher object.
%   - Syntax and variable name changes for clarity.
%   - Extensive commenting.

% $Author: ChrisMcCormick $    $Date: 2014/01/10 22:00:00 $    $Revision: 1.0 $

% Revision notes:
%   v1.0 - 2014/01/10
%     - Initial version.


%{
% ===================================
%       Display Composite Image
% ===================================
% This code will display the left image as a red image and the right image as a
% cyan image on top of one another. You can view the resulting image with red /
% blue glasses to see it in 3D.

% Create a composite image out of the two stereo images.
leftRed = left(:,:,1);

% Take the green and blue color channels from the right image.
rightGreenBlue = right(:,:,2:3);

% Combine the above channels into a single composite image using the 'cat' 
% function, which concatenates the matrices along dimension '3'.
composite = cat(3, leftRed, rightGreenBlue);

% Show the composite image.
figure(1), clf;
image(composite);
axis image;
title('Composite image');
%}

% ====================================
%        Basic Block Matching
% ====================================
% Calculate the disparity using basic block matching with sub-pixel
% estimation.
% The original Mathworks example code utilized the TemplateMatcher from their
% vision toolbox; I've modified the code to work without this dependency.

fprintf('Performing basic block matching...\n');

% Start a timer.
%tic();

% Convert the images from RGB to grayscale by averaging the three color 
% channels.
leftI = mean(left, 3);
rightI = mean(right, 3);

% DispMap will hold the result of the block matching. 
% The values will be 'single' precision (32-bit) floating point.
DispMap = zeros(size(leftI), 'single');

% The disparity range defines how many pixels away from the block's location
% in the first image to search for a matching block in the other image.
disparityRange = 360;

% Define the size of the blocks for block matching.
%halfBlockSize =4; %gerade Zahl wählen
blockSize = 2 * halfBlockSize + 1;

% Get the image dimensions.
[imgHeight, imgWidth] = size(leftI);

% Epipol berechnen
%e1=null(F);

% For each row 'm' of pixels in the image...
for m = 1 : imgHeight
    	
	% Set min/max row bounds for the template and blocks.
	% e.g., for the first row, minr = 1 and maxr = 4
    minr = max(1, m - halfBlockSize);
    maxr = min(imgHeight, m + halfBlockSize);
	
    % For each column 'n' of pixels in the image...
    for n = 1 : imgWidth
        
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
        maxd = min(disparityRange, imgWidth - maxc);

		% Select the block from the right image to use as the template.
        template = rightI(minr:maxr, minc:maxc);
        
		% Bestimmen des Mittelpunktes des Fensters(block)
        CenterPoint=[n;m;1];
        
        % Berechnung der Epipolarlinie im linken Bild
        % Wir benutzen die Epipolarlinien zum Suchen des Korresponierenden
        % Fensters um/da:
        %    1.:Die Anzahl der zu überprüfenden Fenster einzuschränken
        %    2.:Bei uns können die Epipolarlinien (wie in vielen anderen Algorithmen jedoch üblich) 
        %       nicht als waagerecht angenommen werden. Da die Bilder eine Rotation aufweisen. 
		l1=F'*CenterPoint;
        
        % Berechnung aller Pixel, die auf der Epipolarlinie liegen und im
        % Bereich der möglichen Verschiebung liegen.
        Pt1=punkte_auf_linie(l1,left,CenterPoint(1)+mind,CenterPoint(1)+maxd);
        
        %Wenn das Fenster zu nah am Rand ist, kann die Verschiebung nicht
        %berechnet werden. Daher werden die Fenster darauf überprüft und
        %ggf. gleich null gesetzt um sie im darauffolgenden Schritt aus der
        %Epipolarlinie zu löschen
        Pt1(:,Pt1(2,:)<halfBlockSize+1)=0;
        Pt1(:,Pt1(2,:)>imgHeight-halfBlockSize-1)=0;
        Pt1(:,Pt1(1,:)==0)=[];
        Pt1(:,Pt1(2,:)==0)=[];
        
        % Get the number of blocks in this search.
		numBlocks = size(Pt1,2);
        
		% Create a vector to hold the block differences.
		blockDiffs = zeros(numBlocks, 1);
        
        
		if size(Pt1,2)>1
            % Calculate the difference between the template and each of the blocks.
            for i = 1 : size(Pt1,2)

                % Select the block from the left image at the distance 'i'.
                block = leftI(Pt1(2,i)-(m-minr):Pt1(2,i)+(maxr-m), Pt1(1,i)-(n-minc):Pt1(1,i)+(maxc-n));
                
                % Take the sum of absolute differences (SAD) between the template
                % and the block and store the resulting value.
                blockDiffs(i, 1) = sum(sum(abs(template - block)));
            end

            % Sort the SAD values to find the closest match (smallest difference).
            % Discard the sorted vector (the "~" notation), we just want the list
            % of indices.
            [temp, sortedIndeces] = sort(blockDiffs);

            % Get the 1-based index of the closest-matching block.
            bestMatchIndex = sortedIndeces(1, 1);

            % Convert the 1-based index of this block back into an offset.
            % This is the final disparity value produced by basic block matching.
            d = bestMatchIndex + mind - 1;

            % Calculate a sub-pixel estimate of the disparity by interpolating.
            % Sub-pixel estimation requires a block to the left and right, so we 
            % skip it if the best matching block is at either edge of the search
            % window.
            if ((bestMatchIndex == 1) || (bestMatchIndex == numBlocks))
                % Skip sub-pixel estimation and store the initial disparity value.
                DispMap(m, n) = d;
            else
                % Grab the SAD values at the closest matching block (C2) and it's 
                % immediate neighbors (C1 and C3).
                C1 = blockDiffs(bestMatchIndex - 1);
                C2 = blockDiffs(bestMatchIndex);
                C3 = blockDiffs(bestMatchIndex + 1);

                % Adjust the disparity by some fraction.
                % We're estimating the subpixel location of the true best match.
                DispMap(m, n) = d - (0.5 * (C3 - C1) / (C1 - (2*C2) + C3));
            end
        else
                DispMap(m, n) =0;
        end
    end
	% Update progress every 10th row.
	if (mod(m, 10) == 0)
		fprintf('  Image row %d / %d (%.0f%%)\n', m, imgHeight, (m / imgHeight) * 100);
	end
		
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

