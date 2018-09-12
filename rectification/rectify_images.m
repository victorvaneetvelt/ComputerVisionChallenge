function [rect_r, rect_l] = rectify_images(image_r, image_l, varargin)
    
    rect_r = [];
    rect_l = [];

    tries = 1;
    while isempty( rect_r ) || isempty( rect_l )
        F = extract_F(image_r, image_l, varargin{:});
        %F = extractF_with_CV_tool_box(image_r, image_l);

        [rect_r, rect_l] = Rectify_copied( image_r, image_l, F, false);

        if tries > 10 
        %if isempty( rect_r ) || isempty( rect_l )
            error('Cant compute Rectificate images ');
        end
        tries = tries + 1;
    end
end