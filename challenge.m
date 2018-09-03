%% Computer Vision Challenge

% Groupnumber:
group_number = 7;

% Groupmembers:
members = {'Christian Geiger','Moritz Eckhoff','Tobias Betz'};

% Email-Adress (from Moodle!):
 mail = {'christian.geiger@tum.de', 'moritz.eckhoff@tum.de', 'tobias94.betz@tum.de'};

%% Load images
%Image_L = imread('img/L1.JPG');
Image_L = imread('img/L2.JPG');
%Image_R = imread('img/R1.JPG');
Image_R = imread('img/R2.JPG');

%% Free Viewpoint Rendering
% start execution timer -> tic;
tic
%Ansicht zwischen Bilder in Prozent
p=0.5;
%running free_viewpoint function
output_image=free_viewpoint(Image_L, Image_R, p);

% stop execution timer -> toc;
toc
elapsed_time = toc;

%% Display Output
% Display Virtual View
imshow(output_image);

