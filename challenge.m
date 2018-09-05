%% Computer Vision Challenge

% Groupnumber:
group_number = 7;

% Groupmembers:
members = {'Christian Geiger','Moritz Eckhoff','Tobias Betz'};

% Email-Adress (from Moodle!):
 mail = {'christian.geiger@tum.de', 'moritz.eckhoff@tum.de', 'tobias94.betz@tum.de'};

%% Load images
%Image_L = imread('img/L1.JPG');
Image_L_original = imread('img/L2.JPG');
%Image_R = imread('img/R1.JPG');
Image_R_original = imread('img/R2.JPG');

load('img/rect_im_L2.mat');
load('img/rect_im_R2.mat');
Image_L=Rectification_image1;
Image_R=Rectification_image2;
%% Kalibrierungsmatrix
load('K2.mat');
%load('K1.mat');

%% Free Viewpoint Rendering
% start execution timer -> tic;
tic
%Ansicht zwischen Bilder in Prozent
for p=0:0.05:1

%p=0.0;
%running free_viewpoint function
output_image=free_viewpoint(Image_L, Image_R,Image_L_original,Image_R_original, p, K);

% stop execution timer -> toc;


%% Display Output
% Display Virtual View
figure;
imshow(output_image);
end
toc
elapsed_time = toc;