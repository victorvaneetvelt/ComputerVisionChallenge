function DispMap = stereoDisparity_color(left, right, varargin)
    parser =inputParser;
    addOptional(parser,'disparityRange',[-400 400], ...
                                @(n)validateattributes(n, {'numeric'},{}));
    addOptional(parser,'halfBolcksize', 0,@(n)validateattributes(n, ...
                                 {'numeric'},{'scalar','<=',8,'>=',0}));                          
    addOptional(parser,'dispMap_typ', @(n)validateattributes(n, ...
                                 {'char'}, {'scalar'}) );
    addOptional(parser,'scaling', 1,@(n)validateattributes(n, ...
                                  {'numeric'},{'scalar','<=',1,'>=',0.1}));
    addOptional(parser,'do_print',false,@(n)validateattributes(n, ...
                                                {'logical'}, {'scalar'}) );
   
                        
    addOptional(parser,'gui_text_box', matlab.ui.control.TextArea.empty); 
    parse(parser, varargin{:});
    is_text_box = ~isempty(parser.Results.gui_text_box);
    if is_text_box
        text_box = parser.Results.gui_text_box;
    end
    halfBlockSize = parser.Results.halfBolcksize;
    disparityRange = parser.Results.disparityRange;
    do_print = parser.Results.do_print;
   
    start_time = toc;
   
    %% Add Top and Bottom Border to right Image
    right = [zeros(halfBlockSize,size(right,2),3); 
            right;
            zeros(halfBlockSize,size(right,2),3)]; %% Top and Bottom
    right = single(right);
    [r_Height, r_Wide, r_deep] = size(right);

    %% Calculate Left image sizes
    %[~,  l_Wide, ~] = size(left);
    
    %left_index = 1+ abs(disparityRange(1)); % move to left
    %right_index =l_Wide - abs(disparityRange(2)); % move to right
    displacement_range = -1* disparityRange(1) + disparityRange(2)+1;
    %total_size = l_Wide - (abs(disparityRange(1))+  abs(disparityRange(2)));    
    left = [zeros(halfBlockSize,size(left,2),3); 
            left;
            zeros(halfBlockSize,size(left,2),3)]; %% Top and Bottom
    %{
    % cut disparity range out
    left = [zeros(halfBlockSize,total_size,3); 
            left(:,left_index: right_index,:);
            zeros(halfBlockSize,total_size,3)]; %% Top and Bottom
    %}
    left = single(left);
    [l_Height,  l_Wide, l_deep] = size(left);
     
 
    
    %% Right Image to Blocks
    blockSize = halfBlockSize*2+1;
    %right_line = zeros(r_Wide,r_deep,blockSize,blockSize, 'single');
    right_line = zeros(r_Wide,r_deep,blockSize^2, 'single');
    
    %% Weighting Mask
    segment = -(blockSize-1)/2:1:(blockSize-1)/2;
    sigma=sqrt(blockSize/(2*log(2)));
    C=1/(sum(exp(-double(segment).^2/(2*sigma^2))));
    weightedMask=C*exp(-transpose(segment).^2/(2*sigma^2));
    weightedMask = weightedMask*weightedMask';
    %weightedMask_u = cast(1000*weightedMask','uint');
    weightedMask = cast(weightedMask','single');
    weightedMask_tree_color = permute(repmat(weightedMask, [1,1,3]), [3 1 2]);
    weightedMask_tree_color = weightedMask_tree_color(:,:); %block to vector
     
    %% Create DispMap
    DispMap = zeros(l_Height - halfBlockSize*2 , l_Wide, 1, 'single'); 
    
    %% Image limits
    col_limit = r_Height - blockSize + 1;
    r_wide_limit=  r_Wide - blockSize + 1;
    l_wid_limit = l_Wide - blockSize + 1;
    
    
    %% Calculate dispmap
    for y = 1:1:col_limit % iterate over all col
        %% Convert one line from the right image into a vector block
        for x = 1 : 1: r_wide_limit
            block = right(y:y+blockSize-1, x:x+blockSize-1,:);
            block = permute(block, [3 1 2]);
            block = block(:,:); % Block to vector
            right_line(x,:,:) = weightedMask_tree_color.* block;
         end
        %% Set left line
        for x = 1 : 1: l_wid_limit
            % index in right line
            start_index = x + disparityRange(1);
            end_index = start_index + displacement_range;
            % check limits
            start_limted_index = max(1,start_index);
            end_limited_index = min(r_Wide, end_index);
            
            right_frame = right_line(start_limted_index:end_limited_index,:,:);
            right_frame_size = size(right_frame,1);
            index_shift =  start_limted_index - start_index;
          
            
            
            left_block = permute(left(y:y+blockSize-1, x:x+blockSize-1,:), [3 1 2]);
            % convert Block-Matrix into vector
            left_vector = left_block(:,:);
            
            % weight Block for NCC
            left_vector = weightedMask_tree_color.* left_vector;
            
            % 
            left_frame =repmat(left_vector(),[1,1,right_frame_size]);
            left_frame = permute(left_frame, [3 1 2]); % dim: displacement color block
            % construct a right line with big values
               
            %right_frame = right_line(x:x+displacement_range-1,:,:);
            SAP = sum(sum(abs(left_frame - right_frame),2),3);
            [~, NCC_max_index] = min(SAP(:),[],1);
            NCC_max_index = NCC_max_index + index_shift + disparityRange(1) -1;; %displacement 
            
            if NCC_max_index > 1 && NCC_max_index+1<size(SAP,1)
                C1 = SAP(NCC_max_index-1);
                C2 = SAP(NCC_max_index);
                C3 = SAP(NCC_max_index+1);
                NCC_max_index = NCC_max_index - (0.5 * (C3 - C1) / (C1 - (2*C2) + C3));
            end
            
            DispMap(y,x) = NCC_max_index;
        end
        if (mod(y, 10) == 0)
            delta_time = toc - start_time;
            proc = (y / col_limit) * 100;
            if is_text_box
                msg = strcat('DispMap (',num2str(proc,'%03.2f'),'%)'); 
                text_box.Value(2) = {msg};
            end 
            
            if do_print; 
            fprintf('  Image row %d / %d (%.0f%%)', y, col_limit, proc);
            fprintf(' time %.2f min.\n', delta_time / 60.0);
            end
            
            

        end
    end
    
    %save('DispMap_with_color_400_1.mat', 'DispMap', 'blockSize', 'disparityRange');

    %if do_plot 
    %    figure;
    %    imshow(DispMap, disparityRange);
    %    title('Disparity MapML');
    %    colormap(gca,jet) 
    %    colorbar
    %end
    
    end_time = (toc - start_time)/60;
    msg = strcat('Finished after ',num2str(end_time,'%4.2f'),'min');
    if is_text_box; text_box.Value(2) = {msg}; end 
    if do_print; disp(msg);end
    
end
