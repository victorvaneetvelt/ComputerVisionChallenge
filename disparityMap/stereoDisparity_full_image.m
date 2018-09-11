function DispMap = stereoDisparity_full_image(left, right, halfBlockSize, disparityRange, do_plot)
    tic;
    
    %load('img/rect_im_L2.mat');
    %load('img/rect_im_R2.mat');
    
    %[image_height, image_wide, image_deep] = size(Rectification_image1);

    %left = Rectification_image1;
    %right = Rectification_image2;
   [image_height, image_wide, image_deep] = size(left);
    
    %% 
    %NCC_height = 500;
    NCC_deep = abs(disparityRange(1)) + abs(disparityRange(2))+1;
    %NccMap = (2^16 - 1)*ones(NCC_deep,image_height, image_wide, 'uint8');
    NccMap = zeros(NCC_deep,image_height, image_wide, 'uint8');
    
    %diff_image = zeros(image_height, image_wide, 'single');
    DispMap = zeros(image_height, image_wide, 'single');
    
   
 
    
    %% No Shifting
    %diff_image = sum(abs(left(1:500,:,:)-right(1:500,:,:)),3);
    diff_image = sum(abs(single(left)-single(right)),3, 'native');
    
    %if blocksize ==  1
        NccMap(401,:,:) = uint8(diff_image);
    %else
        
    %end
    
    
    %% Shifting to the right
    fprintf('Computing shifting to the right \n');
    for shift = 1:1:400
        % left image shift
        min_index = 1+shift;
        % right image last index of left image size
        max_index = image_wide - shift;
     %   max_index = min_index + image_wide - disparityRange(2);
        % shifting
        index_displacement = abs(disparityRange(1)) + 1 + shift;
        frame_left = single(left(:,min_index:end,:));
        frame_right = single(right(:,1:max_index,:));
        diff_image = (2^16 - 1)*ones(image_height, image_wide, 'single');
        diff_image(:,min_index:end) = sum(abs(frame_left-frame_right),3);
        NccMap(index_displacement,:,:) = uint8(diff_image);
    %
     %   NccMap(index_displacement,:,:) = sum(abs(left(min_index_left:max_index_left,1:500,:)-right(:,1:500,:)),3);
    %if blocksize ==  1
        %NccMap(index_displacement,:,:) = diff_image;
        
    %else
        
    %end
         if (mod(shift, 10) == 0)
            elapsed_time = toc;
            fprintf('  shift left %d / %d', shift, 400);
            fprintf(' time %.2f min.\n', elapsed_time / 60.0);
        end
    end
    
 
    %% Shifiting to the left
    
    fprintf('Computing shifting to the left \n');
    for shift = 1:1:400
        % right image shift
        min_index = 1+shift;
        % left image last index of left image size
        max_index = image_wide - shift;
       
        index_displacement = (abs(disparityRange(1)) + 1) - shift;
        frame_left =  single(left(:,1:max_index,:));
        frame_right =  single(right(:,min_index:end,:));
        
        diff_image = (2^16 - 1)*ones(image_height, image_wide, 'single');
        % place displaced diff image into 
        diff_image(:,1:max_index) = sum(abs(frame_left-frame_right),3);
        NccMap(index_displacement,:,:) = uint8(diff_image);
         
        
        if (mod(shift, 10) == 0)
            elapsed_time = toc;
            fprintf('  shift right %d / %d', shift, 400);
            fprintf(' time %.2f min.\n', elapsed_time / 60.0);
        end
    end
    
    %% Expand to Block compair
    
    blockSize = halfBlockSize*2+1;
    if  blockSize > 1
         fprintf('Computing block diff \n');
        %Add zero bordears
        %NCC_with_borders = zeros(image_height + 2 * halfBlockSize, image_wide + 2 * halfBlockSize, 'uint8');
        
        
        %for displacement_index = 1:1:NCC_deep
            %NCC_with_borders(1+halfBlockSize:image_height + halfBlockSize,1+halfBlockSize:image_wide+halfBlockSize) = NccMap(displacement_index,:,:);
    
            for x = 1:1:image_wide
                min_x = max(1,x-halfBlockSize);
                max_x = min(min_x + halfBlockSize*2, image_wide);
                
                for y = 1:1:image_height
                    min_y = max(1, y-halfBlockSize);
                    max_y = min(min_y + halfBlockSize*2, image_height);
                    block = NccMap(min_y:max_y, min_x:max_x);
                    %block = uint16(block);
                    block = sum(sum(block,2),3)/3; % block is now a double
                    NccMap(:,y,x) = uint8(block); % loss information
                end
            end
        
            if (mod(displacement_index, 10) == 0)
                elapsed_time = toc;
                fprintf('  blocking %d / %d', displacement_index, NCC_deep);
                fprintf(' time %.2f min.\n', elapsed_time / 60.0);
            end
        %end
    else
        [~,DispMap] = min(NccMap,[],1);
        DispMap = squeeze(DispMap);
    end
    
    
    %% Computing the Dispersion Map
      
    % find smalles diff
    %[~,DispMap] = min(NccMap,[],1);
    %DispMap = squeeze(DispMap);
    DispMap = DispMap + disparityRange(1);
    
    if do_plot
        figure;
        imshow(DispMap, disparityRange);
        title('Disparity MapML');
        colormap(gca,jet) 
        colorbar
    %save('DispMap_with_color_2_400_1.mat', 'DispMap', 'blockSize', 'disparityRange');
    end
    


end


function  block_weights= compute_block_weights(blockSize)

    segment = -(blockSize-1)/2:1:(blockSize-1)/2;
    sigma=sqrt(blockSize/(2*log(2)));
    C=1/(sum(exp(-double(segment).^2/(2*sigma^2))));
    weightedMask=C*exp(-transpose(segment).^2/(2*sigma^2));
    weightedMask = weightedMask*weightedMask';
    block_weights = cast(weightedMask','single');

end
