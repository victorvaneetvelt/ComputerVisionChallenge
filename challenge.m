%% Computer Vision Challenge

% Groupnumber:
group_number = 7;

% Groupmembers:
members = {'Christian Geiger','Moritz Eckhoff'};

% Email-Adress (from Moodle!):
 mail = {'christian.geiger@tum.de', 'moritz.eckhoff@tum.de'};

%% Load images
Image_L1 = imread('img/left.png');
%Image_L2 = imread('img/L2.JPG');
Image_R1 = imread('img/right.png');
%Image_R2 = imread('img/R2.JPG');

%% Free Viewpoint Rendering
% start execution timer -> tic;
tic
%Ansicht zwischen Bilder in Prozent
p=0.5;
%running free_viewpoint function
free_viewpoint(Image_L1, Image_R1, p);

% stop execution timer -> toc;
toc
elapsed_time = toc;

%% Display Output
% Display Virtual View
