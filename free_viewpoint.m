function [output_image]  = free_viewpoint(image1, image2, p)
% This function generates an image from a virtual viewpoint between two
% real images. The output image has the same size as the input images.

%In Grauwertbilder konvertieren
IGray1=rgb_to_gray(image1);
IGray2=rgb_to_gray(image2);

% Harris-Merkmale berechnen
 Merkmale1 = harris_detektor(IGray1,'segment_length',9,'k',0.04,'min_dist',50,'N',20,'do_plot',false);
 Merkmale2 = harris_detektor(IGray2,'segment_length',9,'k',0.04,'min_dist',50,'N',20,'do_plot',false);

%% Korrespondenzschaetzung
Korrespondenzen = punkt_korrespondenzen(IGray1,IGray2,Merkmale1,Merkmale2,'window_length',25,'min_corr',0.9,'do_plot',false);

%%  Finde robuste Korrespondenzpunktpaare mit Hilfe des RANSAC-Algorithmus
Korrespondenzen_robust = F_ransac(Korrespondenzen, 'tolerance', 0.04);

%Kalibrierungsmatrix
load('K.mat');

E = achtpunktalgorithmus(Korrespondenzen_robust, K);
F = achtpunktalgorithmus(Korrespondenzen_robust);
[T1, R1, T2, R2]=TR_aus_E(E);
[T,R,~,baseline]=rekonstruktion(T1, T2, R1, R2, Korrespondenzen_robust, K, 'do_plot',false);
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
load('DispMap_left_right.mat', 'DispMap') 
%DispMap=stereoDisparity(F,image1, image2, halfBolcksize, disparityRange ,true);
%save('DispMap_left_right.mat', 'DispMap') 

% Display compute time.
elapsed = toc();
fprintf('Calculating disparity map took %.2f min.\n', elapsed / 60.0);

%% Berechnung des Zwischenbildes
%f=0.024;%Aus Bildinformationen R1 (f=focuslength) 
f=0.032;%Aus Bildinformationen R2 (f=focuslength)
%Das Ergebnis beinhaltet das FreeViewPointBild berechnet aus dem rechten
%Bild mit den Tiefen des rechten Bildes
output_image = Reconstruction3D(DispMap,image2,K,R,T,f,p,disparityRange, baseline);



end
