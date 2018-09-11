function [output_image]  = free_viewpoint(image_r, image_l, varargin)
% This function generates an image from a virtual viewpoint between two
% real images. The output image has the same size as the input images.
% 
    %% Validate Inputs
    parser =inputParser;
    %TODO: max disparityRange
    addOptional(parser,'displacement',1,@(n)validateattributes(n, ...
                                  {'numeric'},{'<=',1,'>=',0.1}));                            
    % ignore disparity variables they will be checked later
    addOptional(parser,'disparity_var', true);                            
    addOptional(parser,'do_print',false,@(n)validateattributes(n, ...
                                   {'logical'}, {'scalar'}) );
    % check if in list
    parse(parser, varargin{:});
    
    do_print = parser.Results.do_print;
    p = parser.Results.displacement;
    dispmat_var = parser.Results.disparity_var;
    

    %% Compute the rectification images
    if do_print; disp('Compute rectified Images');end           
    [rect_r, rect_l] = rectify_images(image_r, image_l, false);
 
    if isempty( rect_r ) || isempty( rect_l )
        disp('Cant compute Rectificate images ');
        %load 'img/rect_im_L2.mat' Rectification_image1;
        %load 'img/rect_im_R2.mat' Rectification_image2;

        %rect_r = Rectification_image1;
        %rect_l = Rectification_image2;
    
    end
    
  
    %% Compute Disparitymaps
    [disp_map_r, disp_map_l] = DisparityMap(rect_r, rect_l, ... 
                                    dispmat_var{:},'do_print', do_print);

    %% Berechnung des Zwischenbildes
    output_image = reconstruction(disp_map_r,disp_map_l, ...
                                   rect_r,rect_l,image_r, image_l, p);
end

function [rect_r, rect_l] = rectify_images(image_r, image_l, do_plot)
    
    addpath('rectification/');    
    % %In Grauwertbilder konvertieren
    image_gray_r = mean(image_r,3);
    image_gray_l = mean(image_l,3);

    % Gausfiltern
    image_gray_r = imgaussfilt( image_gray_r, 1 );
    image_gray_l = imgaussfilt( image_gray_l, 1 );
 
    % compute Harris-features
    features_r = harris_detektor(image_gray_r,'segment_length',15,...
                                'k',0.04,'min_dist',50,'N',5,...
                                'tau',10^6,'do_plot',false);
    features_l = harris_detektor(image_gray_l,'segment_length',15,...
                                'k',0.04,'min_dist',50,'N',5,...
                                'tau',10^5,'do_plot',false);
   
    %Korrespondenzschaetzung
    correspondence = punkt_korrespondenzen(image_gray_r,image_gray_l,...
                                            features_r,features_l, ...
                                            'window_length',25, ...
                                            'min_corr',0.91,...
                                            'do_plot',false);
    %Find stable correspondence pair with the RANSAC-Algorithm
    correspondence_stable = F_ransac(correspondence, 'tolerance', 0.001);

    % compute Fundamental matrix
    F = achtpunktalgorithmus(correspondence_stable);
  
    % Try to compute rectifycation images
    [rect_r, rect_l] = Rectify_copied( image_r, image_l, F, do_plot);
end

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
 
   parse(parser, varargin{:});
   
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
            if do_print; fprintf('Compute the left Disparity Map');end
            
            disp_map_l = stereoDisparity_color(image_l_scaled, image_r_scaled, ...
                                    halfBolcksize, disparityRange, false);
            
            if do_print; fprintf('Compute the right Disparity Map'); end
            
            disp_map_r = stereoDisparity_color(image_r_scaled, image_l_scaled, ...
                                    halfBolcksize, disparityRange, false);
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
            disp_map_l=stereoDisparityoriginal(image_l_scaled, image_r_scaled, ...
                                    halfBolcksize, disparity_dist, false);
            if do_print; fprintf('Compute the right Disparity Map');end
            disp_map_r=stereoDisparityoriginal(image_r_scaled, image_l_scaled, ...
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
    disp_map_r = imresize(disp_map_r,[size(image_r,1), size(image_r,2)]);
    disp_map_l = imresize(disp_map_l,[size(image_l,1), size(image_l,2)]);
end




function output_image=reconstruction(disp_map_r,disp_map_l,rect_r,rect_l,image_r, image_l, p)
    addpath('reconstruction/');
    % Um ein besseres FreeViewPointBild zu berechnen wird anhand der relativen
    % Verschiebung entschieden ob die Berechnung rechtsseitg oder linksseitig erfolgen soll 
    fprintf('Rekonstruktion wird berechnet\n');
    %Das Ergebnis beinhaltet das FreeViewPointBild 
    output_image = Reconstruction3D(disp_map_l,disp_map_r,rect_l,rect_r,p);
    fprintf('Postprocessing wird ausgeführt\n');
    if p<0.5
        output_image=postprocessing(output_image,image_l);
    else
        output_image=postprocessing(output_image,image_r);
    end  
end
