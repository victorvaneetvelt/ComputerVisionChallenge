%% Computer Vision Challenge

% Groupnumber:
group_number = 7;

% Groupmembers:
members = {'Christian Geiger','Moritz Eckhoff','Tobias Betz', 'Victor Van Eetvelt', 'Fabian Uhl'};

% Email-Adress (from Moodle!):
mail = {'christian.geiger@tum.de', 'moritz.eckhoff@tum.de', 'tobias94.betz@tum.de', 'ge72nug@mytum.de', 'Uhl.Fabian@mytum.de'};

%% Load images
Image_L = imread('img/L2.JPG');
Image_R = imread('img/R2.JPG');

%% Kalibrierungsmatrix
%load('result_mats/K2.mat');
%load('result_mats/K1.mat');

%% Definieren des Scaling Faktors
%Scaling=0.3;
Scaling=0.5;
%% Define the size of the blocks for block matching.
halfBolcksize=2;


%% Definieren der Disparity range
% The disparity range defines how many pixels away from the block's location
% in the first image to search for a matching block in the other image.
disparityRange=[-400 400];

%% Free Viewpoint Rendering
% start execution timer -> tic;
tic

%% Displacement factor
%p = 0:0.1:1 all pics
p=0.3;

%% Execute free_viewpoint function
try
    % Global parameter
    disparity_var = {'disparityRange', disparityRange ...
                       ,'halfBolcksize', halfBolcksize ...
                       ,'dispMap_typ', 'colorBlocks' ...
                       };
    
    output_image = free_viewpoint(Image_R, Image_L ...
                                ,'scaling', Scaling ...
                                ,'do_print', true ...
                                ,'displacement',p ...
                                ,'disparity_var',disparity_var ...
                                );
catch inputError
    disp(strcat('ERROR: ', inputError.message))
    return;
end

%% Display Output
% Display Virtual View
figure;
imshow(output_image);

toc
elapsed_time = toc;