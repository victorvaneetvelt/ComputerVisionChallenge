function [output_image]  = free_viewpoint(image1, image2,left_original,right_original, p, K,halfBolcksize,disparityRange)
% This function generates an image from a virtual viewpoint between two
% real images. The output image has the same size as the input images.
% 
% %In Grauwertbilder konvertieren
 IGray1 = mean(image1,3);
 IGray2 = mean( image2,3);

 % Gausfiltern
 IGray1 = imgaussfilt( IGray1, 1 );
 IGray2 = imgaussfilt( IGray2, 1 );
 
% % Harris-Merkmale berechnen
  Merkmale1 = harris_detektor(IGray1,'segment_length',15,'k',0.04,'min_dist',50,'N',5,'tau',10^6,'do_plot',false);
  Merkmale2 = harris_detektor(IGray2,'segment_length',15,'k',0.04,'min_dist',50,'N',5,'tau',10^6,'do_plot',false);
  %Merkmale1 = harris_detektor_fu(IGray1,'segment_length',9,'k',0.04,'min_dist',50,'N',20,'do_plot',false);
  %Merkmale2 = harris_detektor_fu(IGray2,'segment_length',9,'k',0.04,'min_dist',50,'N',20,'do_plot',false);

  
  % 
% %% Korrespondenzschaetzung
 Korrespondenzen = punkt_korrespondenzen(IGray1,IGray2,Merkmale1,Merkmale2,'window_length',25,'min_corr',0.91,'do_plot',true);
% 
% %%  Finde robuste Korrespondenzpunktpaare mit Hilfe des RANSAC-Algorithmus
 Korrespondenzen_robust = F_ransac(Korrespondenzen, 'tolerance', 0.001);
% % 
% % fig = figure(2);
% % fig.NumberTitle = 'off';
% % fig.Name = 'KP robust';
% % imshow(IGray1);
% % hold on;
% % h = imshow(IGray1);      
% % alpha=0.5;
% % set(h, 'AlphaData', alpha);
% % for i=1:size(Korrespondenzen_robust,2)
% %     plot(Korrespondenzen_robust(1,i),Korrespondenzen_robust(2,i),'r+','MarkerSize',10);
% %     plot(Korrespondenzen_robust(3,i),Korrespondenzen_robust(4,i),'b+','MarkerSize',10);
% %     plot(Korrespondenzen_robust(3,i),Korrespondenzen_robust(4,i),'b+','MarkerSize',10);
% %     plot([Korrespondenzen_robust(1,i) Korrespondenzen_robust(3,i)], [Korrespondenzen_robust(2,i) Korrespondenzen_robust(4,i)],'g-','MarkerSize',10);
% % end
% % hold off
% 
%E = achtpunktalgorithmus(Korrespondenzen_robust, K);
 
    
F = achtpunktalgorithmus(Korrespondenzen_robust);



% [T1, R1, T2, R2]=TR_aus_E(E);
% [T,R,~,baseline]=rekonstruktion(T1, T2, R1, R2, Korrespondenzen_robust, K, 'do_plot',false);
% clearvars T1 R1 T2 R2

%% Berechnen der Disparitymap


%tic();
% Um ein besseres FreeViewPointBild zu berechnen wird anhand der relativen
% Verschiebung entschieden ob die Berechnung rechtsseitg oder linksseitig erfolgen soll 
    fprintf('Berechnung der linken Disparity Map');
    %das Ergebnis liefert eine DisparityMap des linken Bildes
    %load('DispMap_rectified_Imagepair_2_left.mat');
    %DispMapLeft=DispMap;
    DispMapLeft=stereoDisparityoriginal(image2, image1, halfBolcksize, disparityRange ,false);
    %save('DispMap_rectified_Imagepair_2_left_skaling0,75.mat', 'DispMap') 
    fprintf('Berechnung der rechten Disparity Map');
    %das Ergebnis liefert eine DisparityMap des rechten Bildes
    %load('DispMap_rectified_Imagepair_2_right.mat');
    %DispMapRight=DispMap;
    DispMapRight=stereoDisparityoriginal(image1, image2, halfBolcksize, disparityRange ,false);
    %save('DispMap_rectified_Imagepair_2_right_skaling0,75.mat', 'DispMap')

% Display compute time.
%elapsed = toc();
%fprintf('Calculating disparity map took %.2f min.\n', elapsed / 60.0);

%% Berechnung des Zwischenbildes

% Um ein besseres FreeViewPointBild zu berechnen wird anhand der relativen
% Verschiebung entschieden ob die Berechnung rechtsseitg oder linksseitig erfolgen soll 
    fprintf('Rekonstruktion wird berechnet');
    %Das Ergebnis beinhaltet das FreeViewPointBild 
    output_image = Reconstruction3D(DispMapLeft,DispMapRight,image1,image2,p);
    fprintf('Postprocessing wird ausgeführt');
    if p<0.5
        output_image=postprocessing(output_image,left_original);
    else
        output_image=postprocessing(output_image,right_original);
    end
end
