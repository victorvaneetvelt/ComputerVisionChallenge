function DispMap=stereoDisparityVictorOld(F, left, right,halfBlockSize, disparityRange, do_plot)


fprintf('Performing basic block matching...\n');

% Convert the images from RGB to grayscale by averaging the three color 
% channels.
% leftI = mean(left, 3);
% rightI = mean(right, 3);

% Get the image dimensions.
[imgHeight, imgWidth] = size(left);

% DispMap will hold the result of the block matching. 
DispMap = zeros(size(left), 'single');

% Define the size of the blocks for block matching.
blockSize = 2 * halfBlockSize + 1;

mStart =  round(imgHeight*1/3);
mStop =  round(imgHeight*1.1/3);
nStart = 1;
nStop = round(imgWidth*1/3);

% For each row 'm' of pixels in the image...
for m = mStart : mStop
    
	% Set min/max row bounds for the template and blocks.
	% e.g., for the first row, minr = 1 and maxr = 4
    minr = max(1, m - halfBlockSize);
    maxr = min(imgHeight, m + halfBlockSize);
	
    % For each column 'n' of pixels in the image...
    for n = nStart : nStop
        
		% Set the min/max column bounds for the template.
		% e.g., for the first column, minc = 1 and maxc = 4
		minc = max(1, n - halfBlockSize);
        maxc = min(imgWidth, n + halfBlockSize);
        
		% Define the search boundaries as offsets from the template location.
		% Limit the search so that we don't go outside of the image. 
		% 'mind' is the the maximum number of pixels we can search to the left.
		% 'maxd' is the maximum number of pixels we can search to the right.
        mind = max(-disparityRange, imgWidth - maxc);
        maxd = min(disparityRange, imgWidth - maxc);

		% Select the block from the right image to use as the template.
        template = right(minr:maxr, minc:maxc);
        
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
                block = left(Pt1(2,i)-(m-minr):Pt1(2,i)+(maxr-m), Pt1(1,i)-(n-minc):Pt1(1,i)+(maxc-n));
                
                % Take the sum of absolute differences (SAD) between the template
                % and the block and store the resulting value.
                blockDiffs(i, 1) = sum(sum(abs(template - block)));
            end

            % Sort the SAD values to find the closest match (smallest difference).
            % Discard the sorted vector (the "~" notation), we just want the list
            % of indices.
            %[temp, sortedIndeces] = sort(blockDiffs);
            [~, DispMap(m,n)]= min(blockDiffs);
        
        end

	eta = toc()/(m-mStart)*(mStop-m);

    
    fprintf('  ETA %.2f min\n', eta / 60.0);
		
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
