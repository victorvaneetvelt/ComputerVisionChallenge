function [output_image]  = free_viewpoint(image_r, image_l, varargin)
% This function generates an image from a virtual viewpoint between two
% real images. The output image has the same size as the input images.
% 
    
    tic;
    %% Validate Inputs
    parser =inputParser;
    
    addOptional(parser,'do_print',false,@(n)validateattributes(n, ...
                                   {'logical'}, {'scalar'}) );
    %addOptional(parser,'displacement', 0.5);
    addOptional(parser,'displacement',1,@(n)validateattributes(n, ...
                                  {'numeric'},{'<=',1,'>=',0.1}));                            
    
    % if default else take given
    addOptional(parser,'disparity_var', {});
    
    % if default else take given
    addOptional(parser,'rectifiy_var', {}); 
    
    % if not set set on empty else take given
    addOptional(parser,'gui_text_box', ...
        matlab.ui.control.TextArea.empty);                
    parse(parser, varargin{:});
    
    do_print = parser.Results.do_print;
    p = parser.Results.displacement;
    dispmat_var = parser.Results.disparity_var;
    rectifiy_var = parser.Results.rectifiy_var;
    
    %% Check is their a text box for prints
    is_text_box = ~isempty(parser.Results.gui_text_box);
    text_box = parser.Results.gui_text_box;


    %% Compute the rectification images
    addpath('rectification/');
    msg = 'Compute rectified Images';
    if do_print; disp(msg);end
    if is_text_box; text_box.Value(1) = {msg}; end 
    [rect_r, rect_l] = rectify_images(image_r, image_l ...
                                      ,rectifiy_var{:} ...
                                      ,'gui_text_box',text_box ...
                                      );


    
  
    %% Compute Disparitymaps
    addpath('disparityMap/');
    [disp_map_r, disp_map_l] = DisparityMap(rect_r, rect_l, ... 
                                    dispmat_var{:}, ...
                                    'do_print', do_print, ...
                                    'gui_text_box', text_box ...
                                    );

    %% Berechnung des Zwischenbildes
    msg = 'reconstruct image';
    if do_print; disp(msg);end
    if is_text_box; text_box.Value = {msg, ''}; end 
    
    
    output_image = reconstruction(disp_map_r,disp_map_l, ...
                                   rect_r,rect_l,image_r, image_l, p);
end


function output_image=reconstruction(disp_map_r,disp_map_l,rect_r,rect_l,image_r, image_l, p)
    addpath('reconstruction/');
    % Um ein besseres FreeViewPointBild zu berechnen wird anhand der relativen
    % Verschiebung entschieden ob die Berechnung rechtsseitg oder linksseitig erfolgen soll 
    %fprintf('Rekonstruktion wird berechnet\n');
    %Das Ergebnis beinhaltet das FreeViewPointBild 
    output_image = Reconstruction3D(disp_map_l,disp_map_r,rect_l,rect_r,p);
    %fprintf('Postprocessing wird ausgeführt\n');
    if p<0.5
        output_image=postprocessing(output_image,image_l);
    else
        output_image=postprocessing(output_image,image_r);
    end  
end
