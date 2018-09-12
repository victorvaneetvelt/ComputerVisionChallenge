function F = extract_F(image_r, image_l, varargin)
  %% Validate Inputs
  %{  
  parser =inputParser;
    % if default else take given
    addOptional(parser,'harris_var', {}); 
    % if default else take given
    addOptional(parser,'correspondence_var', {}); 
    % if default else take given
    addOptional(parser,'ramsac_var', {}); 
    % if not set set on empty else take given
    addOptional(parser,'gui_text_box', ...
        matlab.ui.control.TextArea.empty);                
    parse(parser, varargin{:});
    %}
    harris_var = varargin{2};
    correspondence_var = varargin{4};
    ramsac_var = varargin{6};
    %harris_var = parser.Results.harris_var;
    %correspondence_var = parser.Results.correspondence_var;
    %ramsac_var = parser.Results.ramsac_var;

       
    
    
    %% In Grauwertbilder konvertieren
    image_gray_r = mean(image_r,3);
    image_gray_l = mean(image_l,3);

    %% Gausfiltern
    image_gray_r = imgaussfilt( image_gray_r, 1 );
    image_gray_l = imgaussfilt( image_gray_l, 1 );
 
    % compute Harris-features
    features_r = harris_detektor(image_gray_r,harris_var{:});
    features_l = harris_detektor(image_gray_l,harris_var{:});
    %features_r = harris_detektor(image_gray_r,'segment_length',15,...
    %                            'k',0.04,'min_dist',50,'N',5,...
    %                            'tau',10^6,'do_plot',false);
    %features_l = harris_detektor(image_gray_l,'segment_length',15,...
    %                            'k',0.04,'min_dist',50,'N',5,...
    %                            'tau',10^5,'do_plot',false);
   
    %Korrespondenzschaetzung
    correspondence = punkt_korrespondenzen(image_gray_r,image_gray_l,...
                                            features_r,features_l, ...
                                            correspondence_var{:});
    %correspondence = punkt_korrespondenzen(image_gray_r,image_gray_l,...
    %                                        features_r,features_l, ...
    %                                        'window_length',25, ...
    %                                        'min_corr',0.91,...
    %                                        'do_plot',false);
    %Find stable correspondence pair with the RANSAC-Algorithm
    %correspondence_stable = F_ransac(correspondence, 'tolerance', 0.01);
    correspondence_stable = F_ransac(correspondence, ramsac_var{:},'epsilon',0.7);
    show_correspondence(image_l,image_r,correspondence_stable)
    % compute Fundamental matrix
    F = achtpunktalgorithmus(correspondence_stable);
end