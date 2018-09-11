function DispMap = stereoDisparity_by_blocks(left, right, halfBlockSize, disparityRange, do_plot)
    tic;
    %load('img/rect_im_L2.mat');
    %load('img/rect_im_R2.mat');
    
    %left =  mean(Rectification_image1, 3); % to grey
    %right = mean(Rectification_image2, 3); % to grey
      
    %Add Top and Bottom Border 
    left = double([zeros(halfBlockSize,size(left,2)); 
            left;
            zeros(halfBlockSize,size(left,2))]); %% Top and Bottom

    right = double([zeros(halfBlockSize,size(right,2)); 
            right;
            zeros(halfBlockSize,size(right,2))]); %% Top and Bottom
    
        
    blockSize = halfBlockSize*2+1;
    
    %% Set image blocks per pixel a Block with BlockSize
    %left_blocks = zeros(size(left,1),size(left,2), blockSize, blockSize);
    %right_blocks = zeros(size(right,1),size(right,2), blockSize, blockSize);
    
    %% Block density values 
    left_dv = zeros(size(left,1),size(left,2));
    right_dv = zeros(size(right,1),size(right,2));
    
    %% Weighting mask
    segment = -(blockSize-1)/2:1:(blockSize-1)/2;
    sigma=sqrt(blockSize/(2*log(2)));
    C=1/(sum(exp(-double(segment).^2/(2*sigma^2))));
    weightedMask=C*exp(-transpose(segment).^2/(2*sigma^2));
    weightedMask = weightedMask*weightedMask';
    
    
    
    %% Fillup Blocks
    left_border = size(left,2) - blockSize;
    bottom_border = size(left,1) - blockSize;
    fprintf('Calculate weighted block sums');
    for y = 1: 1: bottom_border
        for x = 1 : 1: left_border
            %left_blocks  (y, x, :, :) =  left(y:y+blockSize-1, x:x+blockSize-1);
            %right_blocks (y, x, :, :) =  right(y:y+blockSize-1, x:x+blockSize-1);
            %% Here happens the magic
            %left_dv(y,x) = sum(sum(weightedMask.* left(y:y+blockSize-1, x:x+blockSize-1)));
            %right_dv(y,x) = sum(sum(weightedMask.* right(y:y+blockSize-1, x:x+blockSize-1)));
            left_dv(y,x) = sum(sum(left(y:y+blockSize-1, x:x+blockSize-1)));
            right_dv(y,x) = sum(sum(right(y:y+blockSize-1, x:x+blockSize-1)));


        end
    end
    %remove top & bottom borders
    left_dv = left_dv(halfBlockSize:end-(halfBlockSize+1),:);
    right_dv = right_dv(halfBlockSize:end-(halfBlockSize+1),:);
    
    %% Calculate NCC for all blocks
    disparityRange = [-250, 250];
    reRange = abs(disparityRange(1)) + abs(disparityRange(2)) + 1;
    %not posible too big
    %NCC = zeros(size(left,1),size(left,2), abs(disparityRange(1)) + abs(disparityRange(2)) + 1);
    %NCC_line =  zeros(abs(disparityRange(1)) + abs(disparityRange(2)) + 1, size(left_dv,2) - reRange);
    NCC_col = zeros(size(left_dv,1), reRange);
    %% remove disparity Range on the left and right side 
    left_dv = left_dv(:, 1 + abs(disparityRange(1)): end - abs(disparityRange(2)) - 1);
    
    %% Iterate over alll displacements from disparityRange(1) to disparityRange(2)
    % reshape left_dv
    
    
    DispMap = zeros(size(left_dv,1), size(left_dv,2));
    for x = 1:1:size(left_dv,2)
        right_frame = right_dv(:, x:reRange - 1 + x); 
        left_frame = repmat(right_dv(:,x), 1, reRange);
        NCC_col = abs(right_frame -left_frame);
        %NCC_col = repmat(right_dv(:,x), 1, reRange) - left_dv(:,x:reRange);
        [NCC_max, NCC_max_index] = max(NCC_col,[],2);
        
        DispMap(:,x) = NCC_max_index + disparityRange(1);
    end
    %DispMap = [NCC_max_index];
    figure;
    imshow(DispMap, disparityRange);
    title('Disparity MapML');
    colormap(gca,jet) 
    colorbar

    
    elapsed_time = toc;
    fprintf('Calculating disparity map took %.2f min.\n', elapsed_time / 60.0);
   hans =2 ; 
end
