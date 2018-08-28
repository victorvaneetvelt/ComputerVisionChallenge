function [output_image]  = free_viewpoint(image1, image2, p)
% This function generates an image from a virtual viewpoint between two
% real images. The output image has the same size as the input images.
set(0,'DefaultFigureWindowStyle','docked')

%% Converd image to grey
IGray1=rgb_to_gray(image1);
IGray2=rgb_to_gray(image2);

%% Calculate Harris-Merkmale
Merkmale1 = harris_detektor(IGray1,'segment_length',15,'k',0.05,'min_dist',50,'N',20,'do_plot',false);
Merkmale2 = harris_detektor(IGray2,'segment_length',15,'k',0.05,'min_dist',50,'N',20,'do_plot',false);

%% Korrespondenzschaetzung
% Korrespondenz Punkten
Korrespondenzen = punkt_korrespondenzen(IGray1,IGray2,Merkmale1,Merkmale2,'window_length',25,'min_corr',0.9,'do_plot',false);

fig = figure(1);
fig.NumberTitle = 'off';
fig.Name = 'KP';
imshow(image1);
hold on;
h = imshow(image2);      
alpha=0.5;
set(h, 'AlphaData', alpha);
for i=1:size(Korrespondenzen,2)
    plot(Korrespondenzen(1,i),Korrespondenzen(2,i),'r+','MarkerSize',10);
    plot(Korrespondenzen(3,i),Korrespondenzen(4,i),'b+','MarkerSize',10);
    plot(Korrespondenzen(3,i),Korrespondenzen(4,i),'b+','MarkerSize',10);
    plot([Korrespondenzen(1,i) Korrespondenzen(3,i)], [Korrespondenzen(2,i) Korrespondenzen(4,i)],'g-','MarkerSize',10);
end
hold off

%%  Finde robuste Korrespondenzpunktpaare mit Hilfe des RANSAC-Algorithmus
% Selection of the best Korrespondenz Points
Korrespondenzen_robust = F_ransac(Korrespondenzen, 'tolerance', 0.04);

fig = figure(2);
fig.NumberTitle = 'off';
fig.Name = 'KP robust';
imshow(image1);
hold on;
h = imshow(image2);      
alpha=0.5;
set(h, 'AlphaData', alpha);
for i=1:size(Korrespondenzen_robust,2)
    plot(Korrespondenzen_robust(1,i),Korrespondenzen_robust(2,i),'r+','MarkerSize',10);
    plot(Korrespondenzen_robust(3,i),Korrespondenzen_robust(4,i),'b+','MarkerSize',10);
    plot(Korrespondenzen_robust(3,i),Korrespondenzen_robust(4,i),'b+','MarkerSize',10);
    plot([Korrespondenzen_robust(1,i) Korrespondenzen_robust(3,i)], [Korrespondenzen_robust(2,i) Korrespondenzen_robust(4,i)],'g-','MarkerSize',10);
end
hold off

%% Essencial- & FundamentalMatrix
% Load Camera Parameters
load('K.mat');

% Essencial Matrix
E = achtpunktalgorithmus(Korrespondenzen_robust, K);
% Fundamental Matrix
F = achtpunktalgorithmus(Korrespondenzen_robust);

%% Rectification
[~, nbKP_robust] = size(Korrespondenzen_robust);
x1 = [Korrespondenzen_robust(1:2, :);ones(1,nbKP_robust)];
x2 = [Korrespondenzen_robust(3:4, :);ones(1,nbKP_robust)];
[rect1, rect2] = rectify_images(IGray1, IGray2, x1, x2, F);
figure
imshow(rect1);
figure
imshow(rect2);

[T1, R1, T2, R2]=TR_aus_E(E);
[T,R,lambda_Korr_robust]=rekonstruktion(T1, T2, R1, R2, Korrespondenzen_robust, K, 'do_plot',false);
clearvars T1 R1 T2 R2

%% Berechnen der Disparitymap

% Define the size of the blocks for block matching.
halfBolcksize=4; %gerade Zahl wählen!!
% The disparity range defines how many pixels away from the block's location
% in the first image to search for a matching block in the other image.
%Die 250 sind ein guter Wert für unsere Bilder. Das sieht man wenn man die
%Koordinaten der zusammenpassenden Merkmalspunkte vergleicht. Also schaut
%wie viele Pixel diese Punkte auseinander liegen.
disparityRange=50;
tic();
%das Ergebnis liefert eine DisparityMap des rechten Bildes
DispMap=stereoDisparity(F,image1, image2, halfBolcksize, disparityRange ,true);
% Display compute time.
elapsed = toc();
fprintf('Calculating disparity map took %.2f min.\n', elapsed / 60.0);

%% Berechnung des Zwischenbildes
f=32;%Aus Bildinformationen (f=focuslength)
%Das Ergebnis beinhaltet das FreeViewPointBild berechnet aus dem rechten
%Bild mit den Tiefen des rechten Bildes
output_image = Reconstruction3D(DispMap,image2,K,R,T,f,p,disparityRange);



end
