 function [Reconstruction] = Reconstruction3D(DispMap,image,p)

% Definieren des Rekonstruierten Bildes
Reconstruction=zeros(size(image),'uint8');
% 
% %Schleife Ã¼ber jeses Pixel des Bildes in x und y Koordinaten
% % i entspricht x und j entspricht y
% for i=1:size(image,2)
%    for j=1:size(image,1)
%        
%        %Berechnung der der X-Koordinate des Pixels (i,j) im freeviewpoint
%        %Bild
%        P2=DispMap(j,i)*p+i;
%       
%        %Mit der Kalibrierungsmatrix zurÃ¼ck auf Pixelkoordinaten rechnen und
%        %runden um ganzzahlige Pixelkoordinaten zu erhalten
%        P2=round(P2);
%        
%        % PrÃ¼fen ob die Berechnete Koordinate im Rahmen des Bildes liegt
%        if P2>0&&P2<size(image,2)
%            
%            %Ã¼bertragen der Farbwerte vom gegebenen Bild in das virtuelle Bild
%             Reconstruction(j,P2,:)=image(j,i,:);
%        end
%    end
% end
% imshow(Reconstruction);
% title('ohne Tiefenbetrachtung');
% figure;

% Sortieren aller Verschiebungen der DispMap damit, wenn 2 oder mehr 
% Bildpunkte im FreeViewPointBild auf den selben Pixel projiziert werden, 
% der Pixel des weiter vorne liegenden Gegenstandes dargestellt wird.
[~, SortedIndexDispMap]=sort(DispMap(:));

% Schleife über alle Pixel des Bildes
for i=1:1:size(image,1)*size(image,2)
    
    % ermitteln der x und y Koordinate des Pixels
    [y,x]=ind2sub(size(DispMap),SortedIndexDispMap(i));
    
    % Mit hilfe der Dispmap und der relativen Verschiebeung wird die neue x
    % Koordinate für das FreeViewPointBild berechnet
    x_new=round(DispMap(y,x)*p+x);
    
    % Prüfen ob die neue x Koordinate innerhalb des Bildes liegt
    if x_new>0&&x_new<size(image,2)
    
        %Übertragen der Farbwerte vom gegebenen Bild in das virtuelle Bild
        Reconstruction(y,x_new,:)=image(y,x,:);
    end
end
 end