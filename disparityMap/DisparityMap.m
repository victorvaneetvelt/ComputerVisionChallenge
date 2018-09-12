function[disp_map_r, disp_map_l] = DisparityMap(image_r, image_l, varargin)
   %% Compute the Disparity Map 
   % DisparityMap shows the distance to the pixel with a high similarity
   % halfblocksize define the size of the block, which will compair
   % disparityRange is the max range in the left and right seeking direction

   %% Validate Inputs 
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
   halfBolcksize = parser.Results.halfBolcksize;
   disparityRange = parser.Results.disparityRange;
   typ = parser.Results.dispMap_typ;
   Scaling = parser.Results.scaling;
   do_print = parser.Results.do_print;
                             
   %% Perform Scaling for computation performance
   image_r_scaled = imresize(image_r, Scaling);
   image_l_scaled = imresize(image_l, Scaling);
   disparityRange=disparityRange.*Scaling;
   
   %% Compute left and right disparity Map
   addpath('disparityMap/');
   switch typ
        case 'colorBlocks'
            
            msg = 'Compute the left Disparity Map';
            if is_text_box; text_box.Value = {msg, ''}; end 
            if do_print; disp(msg);end
            
            disp_map_l = stereoDisparity_color(image_l_scaled, image_r_scaled, ...
                                                varargin{:});
            msg = 'Compute the right Disparity Map';
            if is_text_box; text_box.Value = {msg, ''}; end 
            if do_print; disp(msg);end
            disp_map_r = stereoDisparity_color(image_r_scaled, image_l_scaled, ...
                                                varargin{:});
       case 'fullImage'
            if do_print; fprintf('Compute the left Disparity Map');end
           
            disp_map_l = stereoDisparity_full_image(image_l_scaled, image_r_scaled,  ...
                                                0, disparityRange, false);
            if do_print; fprintf('Compute the right Disparity Map');end
            disp_map_r = stereoDisparity_full_image(image_r_scaled, image_l_scaled,  ...
                                                0, disparityRange, false);
          
       case 'load'
            if do_print; fprintf('load the left Disparity Map');end
            load 'DispMap_rectified_Imagepair_2_left.mat' DispMap;
            disp_map_l = DispMap;
            if do_print; fprintf('load the left Disparity Map');end
            load 'DispMap_rectified_Imagepair_2_right.mat' DispMap;
            disp_map_r = DispMap;

       case 'original'
            disparity_dist = abs(disparityRange(1));
            if do_print; fprintf('Compute the left Disparity Map');end
            disp_map_l=stereoDisparityoriginal(image_r_scaled, image_l_scaled, ...
                                    halfBolcksize, disparity_dist, false);
            if do_print; fprintf('Compute the right Disparity Map');end
            disp_map_r=stereoDisparityoriginal(image_l_scaled, image_r_scaled, ...
                                    halfBolcksize, disparity_dist ,false);
 
       otherwise
            if do_print; fprintf('Compute the left Disparity Map');end
            disp_map_l = stereoDisparity_color(image_l_scaled, image_r_scaled, ...
                                    halfBolcksize, disparityRange, false);
            if do_print; fprintf('Compute the right Disparity Map');end
            disp_map_r = stereoDisparity_color(image_r_scaled, image_l_scaled, ...
                                    halfBolcksize, disparityRange, false);
   end
   
   %% Scale the disparity maps up to the original size

    disp_map_r = imresize(disp_map_r,[size(image_r,1), size(image_r,2)],'bilinear');
    disp_map_l = imresize(disp_map_l,[size(image_l,1), size(image_l,2)],'bilinear');
    disp_map_r=disp_map_r./Scaling;
    disp_map_l=disp_map_l./Scaling;
end
