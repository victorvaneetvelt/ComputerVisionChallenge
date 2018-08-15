 function [Reconstruction] = Reconstruction3D(DispMap,image,K,R,T,f,p,disparityRange, baseline)

%Die DispMap auf nur positive Verschiebungen umrechnen
DispMap=-(DispMap-disparityRange);

% Berechnen der Tiefen aus der Verschiebung
%       Die Ergebnise sind vermutlich nicht korrekt. Die Formel dafür haben
%       wir aus der PDF-Datei "Coste - Stereo and 3D Reconstruction from
%       Disparity" Seite 20 (von Moodle)
z=(f*baseline)./DispMap;
figure;
imshow(z);
title('Depth map');

% Definieren des Rekonstruierten Bildes
Reconstruction=zeros(size(image));

% Berechnen von Inversen für spätere Zwecke
%Rinv=R^-1;
Kinv=K^-1;

%Schleife über jeses Pixel des Bildes in x und y Koordinaten
% i entspricht x und j entspricht y
for i=1:size(image,2)
   for j=1:size(image,1)
       
       %Berechnung der Weltkoordinaten des Pixels(j,i) mit hilfe der Formel
       %für die euklidsche Bewegung und dem Bezugssystem des Zwischenbildes
       %P2=Kinv*z(j,i)*p*Rinv*[i;j;1]-p*Rinv*T;
       P2=Kinv*z(j,i)*p*R*[i;j;1]+p*T;
       
       % homogenisieren des Pixels (Auf dei Bildebene Projezieren)
       P2=P2/P2(3);
       
       %Mit der Kalibrierungsmatrix zurück auf Pixelkoordinaten rechnen und
       %runden um ganzzahlige Pixelkoordinaten zu erhalten
       x2=round(K*P2);
       
       % Prüfen ob die Berechnete Koordinate im Rahmen des Bildes liegt
       if x2(1)>0&&x2(1)<size(image,2)&& x2(2)>0&&x2(2)<size(image,1)
           
           %übertragen der Farbwerte vom gegebenen Bild in das virtuelle Bild
            Reconstruction(x2(2),x2(1),:)=image(j,i,:);
       end
   end
end
figure;
imshow(Reconstruction);
title('Reconstruction');

 end