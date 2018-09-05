function DispMap = stereoDisparity_color(left, right, halfBlockSize, disparityRange, do_plot)
    tic;
    load('img/rect_im_L2.mat');
    load('img/rect_im_R2.mat');
    
    left = Rectification_image1;
    right = Rectification_image2;
    clearvars Rectification_image1 Rectification_image2
    %left =  mean(Rectification_image1, 3); % to grey
    %right = mean(Rectification_image2, 3); % to grey

    %% Sizes 
    %[r_Height, r_Wide, r_deep] = size(right);

    %% Add Top and Bottom Border to right Image
    right = [zeros(halfBlockSize,size(right,2),3); 
            right;
            zeros(halfBlockSize,size(right,2),3)]; %% Top and Bottom
    right = single(right);
    [r_Height, r_Wide, r_deep] = size(right);

    %% Calculate Left image sizes
    [~,  l_Wide, ~] = size(left);
    
    left_index = 1+ abs(disparityRange(1)); % move to left
    right_index =l_Wide - abs(disparityRange(2)); % move to right
    displacement_range = -1* disparityRange(1) + disparityRange(2)+1;
    total_size = l_Wide - (abs(disparityRange(1))+  abs(disparityRange(2)));    
    left = [zeros(halfBlockSize,total_size,3); 
            left(:,left_index: right_index,:);
            zeros(halfBlockSize,total_size,3)]; %% Top and Bottom
    left = single(left);
    [l_Height,  l_Wide, l_deep] = size(left);
     
  %% Create DispMap
    DispMap = zeros(l_Height, l_Wide, 1, 'single');    
    
    %% Right Image to Blocks
    blockSize = halfBlockSize*2+1;
    right_line = zeros(r_Wide,r_deep,blockSize,blockSize, 'single');
    
    %% Weighting Mask
    segment = -(blockSize-1)/2:1:(blockSize-1)/2;
    sigma=sqrt(blockSize/(2*log(2)));
    C=1/(sum(exp(-double(segment).^2/(2*sigma^2))));
    weightedMask=C*exp(-transpose(segment).^2/(2*sigma^2));
    weightedMask = weightedMask*weightedMask';
    %weightedMask_u = cast(1000*weightedMask','uint');
    weightedMask = cast(weightedMask','single');
    weightedMask_tree_color = permute(repmat(weightedMask, [1,1,3]), [3 1 2]);
    weightedMask_lead_1 = reshape(weightedMask_tree_color, [1,size(weightedMask_tree_color)]);
     
    %% NCC_lines
    %NCC = zeros(l_Wide, displacement_range);
    %% Image limits
    col_limit = r_Height - blockSize;
    r_wide_limit=  r_Wide - blockSize;
    l_wid_limit = l_Wide - blockSize;
    
    for y = 1:1:col_limit % iterate over all col
    %y = 1
   
        %% Set right line
        %right_line = build_right_line(right,y, r_Wide, blockSize);
        for x = 1 : 1: r_wide_limit
            k = right(y:y+blockSize-1, x:x+blockSize-1,:);
            right_line(x,:,:,:) = permute(k, [3 1 2]);
            right_line(x,:,:,:) = weightedMask_lead_1.*  right_line(x,:,:,:);
        end
        %% Set left line
        for x = 1 : 1: l_wid_limit
            left_block = permute(left(y:y+blockSize-1, x:x+blockSize-1,:), [3 1 2]);
            left_block = weightedMask_tree_color.* left_block;
            left_frame =repmat(left_block(),[1,1,1,displacement_range]);
            right_frame =  permute(right_line(x:x+displacement_range-1,:,:,:), [2 3 4 1]);
            %diff = bsxfun(@minus, left_block, right_frame); % takes longer
            %SAP = sum(sum(sum(abs(diff),1),2),3);
            SAP = sum(sum(sum(abs(left_frame - right_frame),1),2),3);
            [~, NCC_max_index] = min(SAP(:),[],1);
            %list = sort(SAP(:),1);
            %NCC_max_index = list(1);
            if NCC_max_index > 1 && NCC_max_index+1<size(NCC_max_index,4)
                C1 = SAP(1,1,1,NCC_max_index-1);
                C2 = SAP(1,1,1,NCC_max_index);
                C3 = SAP(1,1,1,NCC_max_index+1);
                NCC_max_index = NCC_max_index - (0.5 * (C3 - C1) / (C1 - (2*C2) + C3));
            end
            DispMap(y,x) = NCC_max_index + disparityRange(1) -1;
        end
        if (mod(y, 10) == 0)
            fprintf('  Image row %d / %d (%.0f%%)\n', y, col_limit, (y / col_limit) * 100);
        end
    end
    save('DispMap_with_color_250_9.mat', 'DispMap', 'blockSize', 'disparityRange');

    figure;
    imshow(DispMap, disparityRange);
    title('Disparity MapML');
    colormap(gca,jet) 
    colorbar
    
    
    elapsed_time = toc
    fprintf('Calculating disparity map took %.2f min.\n', elapsed_time / 60.0);
   hans =2 ; 
end
function  right_line = build_right_line(right,y, r_Wide, blockSize)
        for x = 1 : 1: r_Wide - blockSize
            right_line(x,:,:,:) = permute(right(y:y+blockSize-1, x:x+blockSize-1,:), [3 1 2]);
            %right_line(x,:,:,:) = double(right_line(x,:,:,:));
            %right_line(x,:,:,:) = weightedMask_lead_1.*  right_line(x,:,:,:);
        end
end


function sub_pixel = sub_pixel_computation(area_pixel)
            % values are the values 
			% Grab the SAD values at the closest matching block (C2) and it's 
			% immediate neighbors (C1 and C3).
			C1 = area_pixel(1);
			C2 = area_pixel(2)
			C3 = area_pixel(3);
			
			% Adjust the disparity by some fraction.
			% We're estimating the subpixel location of the true best match.
			sub_pixel = d - (0.5 * (C3 - C1) / (C1 - (2*C2) + C3));
end