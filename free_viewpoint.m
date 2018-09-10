function [output_image]  = free_viewpoint(image_r, image_l, p, halfBolcksize,disparityRange, Scaling)
% This function generates an image from a virtual viewpoint between two
% real images. The output image has the same size as the input images.
% 
    %%Compute the rectification images
    [rect_r, rect_l] = rectify_images(image_r, image_l);
    %load 'img/rect_im_L2.mat' Rectification_image1;
    %load 'img/rect_im_R2.mat' Rectification_image2;
    
    %rect_r = Rectification_image1;
    %rect_l = Rectification_image2;
 
    
    
    %% Scale down image for computation performance
    rect_r = imresize(rect_r, Scaling);
    rect_l = imresize(rect_l, Scaling);
    image_r = imresize(image_r, Scaling);
    image_l = imresize(image_l, Scaling);
  
    %% Compute Disparitymaps       git
    [disp_map_r, disp_map_l] = Disparity_color_by_blocks(rect_r, rect_l, 1,[-400 400]);
    
    %[disp_map_r, disp_map_l] = Disparity_color_total_image(rect_r, rect_l, halfBolcksize,disparityRange);
        

    %% Berechnung des Zwischenbildes
    output_image = reconstruction(disp_map_r,disp_map_l, ...
                                   rect_r,rect_l,image_r, image_l, p);
    % Scale image to original size
    output_image=imresize(output_image,1/Scaling);
end

function [rect_r, rect_l] = rectify_images(image_r, image_l)
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
                                'tau',10^6,'do_plot',false);
   
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
    [rect_r, rect_l] = Rectify_copied( image_r, image_l, F);
      
    if isempty( rect_r ) || isempty( rect_l )
        % I doen't work load matlab F matrix
        load 'F_matlab.mat' 'F';
        [rect_r, rect_l] = Rectify_copied( image_r, image_l, F);
    end
    if isempty( rect_r ) || isempty( rect_l )
        disp('Cant compute Rectificate images ');
    end
end

function[disp_map_r, disp_map_l] = Disparity_color_by_blocks( ...
                        image_r, image_l, halfBolcksize,disparityRange)
    fprintf('Compute the left Disparity Map');
    disp_map_l = stereoDisparity_color(image_l, image_r, halfBolcksize, disparityRange, false);
    fprintf('Berechnung der rechten Disparity Map');
    disp_map_r = stereoDisparity_color(image_r, image_l, halfBolcksize, disparityRange, false);

    %wide = abs(disparityRange(1));
    %height = size(disp_map_l,1);
    
    % back to original size
    %disp_map_l = [zeros(height, wide), disp_map_l, zeros(height, wide)];
    %disp_map_r = [zeros(height, wide), disp_map_r, zeros(height, wide)];
   
end

function [disp_map_r, disp_map_l] = Disparity_color_total_image(...
                        image_r, image_l, halfBolcksize,disparityRange)
    %tic();
    % Um ein besseres FreeViewPointBild zu berechnen wird anhand der relativen
    % Verschiebung entschieden ob die Berechnung rechtsseitg oder linksseitig erfolgen soll 
    fprintf('Compute the left Disparity Map');
    %das Ergebnis liefert eine DisparityMap des linken Bildes
    %% load DispMap
    %load('DispMap_rectified_Imagepair_2_left.mat');
    %DispMapLeft=DispMap;
    
    %% compute old DispMap
    %DispMapLeft=stereoDisparityoriginal(image_l, image_r, halfBolcksize, disparityRange ,false);
    
    %% compute new DispMap
    disp_map_l = DispMap_color_blocks_2(image_l, image_r, 0, [-400 400], false);
    
    
    %save('DispMap_rectified_Imagepair_2_left_skaling0,75.mat', 'DispMap') 
    fprintf('Berechnung der rechten Disparity Map');
    %das Ergebnis liefert eine DisparityMap des rechten Bildes
    
    %% load DispMap
    %load('DispMap_rectified_Imagepair_2_right.mat');
    %DispMapRight=DispMap;
  
    %% compute old DispMap
    %DispMapRight=stereoDisparityoriginal(image1, image2, halfBolcksize, disparityRange ,false);
    %save('DispMap_rectified_Imagepair_2_right_skaling0,75.mat', 'DispMap')
    
    %% compute new DispMap
    disp_map_r = DispMap_color_blocks_2(image_r, image_l, 0, [-400 400], false);

    % Display compute time.
    %elapsed = toc();
    %fprintf('Calculating disparity map took %.2f min.\n', elapsed / 60.0);

end

function output_image=reconstruction(disp_map_r,disp_map_l,rect_r,rect_l,image_r, image_l, p)
    % Um ein besseres FreeViewPointBild zu berechnen wird anhand der relativen
    % Verschiebung entschieden ob die Berechnung rechtsseitg oder linksseitig erfolgen soll 
    fprintf('Rekonstruktion wird berechnet');
    %Das Ergebnis beinhaltet das FreeViewPointBild 
    output_image = Reconstruction3D(disp_map_l,disp_map_r,rect_l,rect_r,p);
    fprintf('Postprocessing wird ausgeführt');
    if p<0.5
        output_image=postprocessing(output_image,image_l);
    else
        output_image=postprocessing(output_image,image_r);
    end  
end
