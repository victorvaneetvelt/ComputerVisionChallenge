 function [Reconstruction] = Reconstruction3D(DispMap,image,p)

% Definieren des Rekonstruierten Bildes
Reconstruction=zeros(size(image),'uint8');

%Schleife über jeses Pixel des Bildes in x und y Koordinaten
% i entspricht x und j entspricht y
for i=1:size(image,2)
   for j=1:size(image,1)
       
       %Berechnung der der X-Koordinate des Pixels (i,j) im freeviewpoint
       %Bild
       P2=DispMap(j,i)*p+i;
      
       %Mit der Kalibrierungsmatrix zurück auf Pixelkoordinaten rechnen und
       %runden um ganzzahlige Pixelkoordinaten zu erhalten
       P2=round(P2);
       
       % Prüfen ob die Berechnete Koordinate im Rahmen des Bildes liegt
       if P2>0&&P2<size(image,2)
           
           %übertragen der Farbwerte vom gegebenen Bild in das virtuelle Bild
            Reconstruction(j,P2,:)=image(j,i,:);
       end
   end
end

 end