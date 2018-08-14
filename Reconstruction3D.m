 function [Reconstruction] = Reconstruction3D(DispMap,image1,K,R,T,f,p,disparityRange)
%imshow(image1)
%Die DispMap auf nur positive Verschiebungen umrechnen
DispMap=-(DispMap-disparityRange);

% Berechnen der Tiefen aus der Verschiebung
%       Die Ergebnise sind vermutlich nicht korrekt. Die Formel dafür haben
%       wir aus der PDF-Datei "Coste - Stereo and 3D Reconstruction from
%       Disparity" Seite 20 (von Moodle)
z=(f*T(1))./DispMap;
%z=DispMap;
% Definieren des Rekonstruierten Bildes
Reconstruction=zeros(size(image1));

% Berechnen von Inversen für spÃ¤tere Zwecke
%Rinv=R^-1;
Kinv=K^-1;
%pi_0=[1 0 0 0;0 1 0 0; 0 0 1 0];
%RT=[R T;0 0 0 1];

%Schleife Über jeses Pixel des Bildes in x und y Koordinaten
% i entspricht x und j entspricht y
for i=1:size(image1,2)
   for j=1:size(image1,1)
       
       %Berechnung der Weltkoordinaten des Pixels(j,i) mit hilfe der Formel
       %für die euklidsche Bewegung und dem Bezugssystem des Zwischenbildes
       %P2=Kinv*z(j,i)*p*Rinv*[i;j;1]-p*Rinv*T;
       P2=Kinv*z(j,i)*p*R*[i;j;1]+p*T;

%        p_0=z(i,j)*[i;j;1];
%        p_hom=[p_0;1];
%        P2=pi_0*RT*p_hom;
       %x_pixel= x_pixel/ x_pixel(3);
       % homogenisieren des Pixels (Auf die Bildebene Projezieren)
       P2=P2/P2(3);
       
       %Mit der Kalibrierungsmatrix zurück auf Pixelkoordinaten rechnen und
       %runden um ganzzahlige Pixelkoordinaten zu erhalten
       %x2=round(K*P2);
       x2=round(P2);
       
       % Prüfen ob die Berechnete Koordinate im Rahmen des Bildes liegt
       if x2(1)>0&&x2(1)<size(image1,2)&& x2(2)>0&&x2(2)<size(image1,1)
           
           %Übertragen der Farbwerte vom gegebenen Bild in das virtuelle Bild
                Reconstruction(x2(2),x2(1),:)=image1(j,i,:);
  
       end
   end
end

%imshow(FreeViewPoint);

 end