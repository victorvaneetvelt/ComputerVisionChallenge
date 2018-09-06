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

%% Definieren des Skaling Faktors
Skaling=0.75;

%% Define the size of the blocks for block matching.
halfBolcksize=4; %gerade Zahl wählen!!
% The disparity range defines how many pixels away from the block's location
% in the first image to search for a matching block in the other image.

%% Definieren der Disparity range
%Die 400 sind ein guter Wert für unsere Bilder. Das sieht man wenn man die
%Koordinaten der zusammenpassenden Merkmalspunkte vergleicht. Also schaut
%wie viele Pixel diese Punkte auseinander liegen.
disparityRange=400;

%% Free Viewpoint Rendering
% start execution timer -> tic;
tic
%Ansicht zwischen Bilder in Prozent
for p=0:0.05:1

%p=0.5;
%running free_viewpoint function
output_image=free_viewpoint(imresize(Image_L, Skaling), imresize(Image_R, Skaling),imresize(Image_L_original,Skaling),imresize(Image_R_original,Skaling), p, K, halfBolcksize, disparityRange*Skaling);
output_image=imresize(output_image,1/Skaling);
% stop execution timer -> toc;


%% Display Output
% Display Virtual View
figure;
imshow(output_image);
end
toc
elapsed_time = toc;