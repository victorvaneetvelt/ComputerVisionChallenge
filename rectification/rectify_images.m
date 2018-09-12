function [rect_r, rect_l] = rectify_images(image_r, image_l, varargin)
        %Compute F 
    %F = extract_F(image_r, image_l, varargin{:});
    %F = extractF_with_CV_tool_box(image_r, image_l);
    % Try to compute rectifycation images
    tries = 0;
    
    rect_r = [];
    rect_l = [];
    tol = 0.1;
    while isempty(rect_r) || isempty(rect_l)
        tries = tries+1;
        disp('compute F');
        F = extract_F(image_r, image_l, varargin{:});
        %F = extractF_with_CV_tool_box(image_r, image_l);
        disp(strcat('Rectify images try: ',num2str(tries,'%d'), ' with tolerance: ',num2str(tol,'%f')));
        [rect_r, rect_l] = Rectify_copied( image_r, image_l, F,tol, false);
        tol = tol;
        %If Rectify doest work rect_r and rect_l are empty
        if tries > 10
            error('Cant compute rectified images');
            return;
        end

end