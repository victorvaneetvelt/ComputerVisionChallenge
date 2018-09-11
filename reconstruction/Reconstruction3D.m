 function [Reconstruction] = Reconstruction3D(DispMapLeft, DispMapRight,left,right,p)

% Definieren des Rekonstruierten Bildes
Reconstruction=zeros(size(right),'uint8');
Reconstruction2=zeros(size(right),'uint8');

% Sortieren aller Verschiebungen der DispMap damit, wenn 2 oder mehr 
% Bildpunkte im FreeViewPointBild auf den selben Pixel projiziert werden, 
% der Pixel des weiter vorne liegenden Gegenstandes dargestellt wird.
[~, SortedIndexDispMapLeft]=sort(DispMapLeft(:),'descend');
[~, SortedIndexDispMapRight]=sort(DispMapRight(:));
if p<0.5
    SortedIndexDispMap1=SortedIndexDispMapLeft;
    image1=left;
    DispMap1=DispMapLeft;
    relativeDisp1=p;
    SortedIndexDispMap2=SortedIndexDispMapRight;
    image2=right;
    DispMap2=DispMapRight;
    relativeDisp2=1-p;
else
    SortedIndexDispMap1=SortedIndexDispMapRight;
    image1=right;
    DispMap1=DispMapRight;
    relativeDisp1=1-p;
    SortedIndexDispMap2=SortedIndexDispMapLeft;
    image2=left;
    DispMap2=DispMapLeft;
    relativeDisp2=p;
end
% Schleife über alle Pixel des Bildes
for i=1:1:size(image1,1)*size(image1,2)

    % ermitteln der x und y Koordinate des Pixels
    [y,x]=ind2sub(size(DispMap1),SortedIndexDispMap1(i));
    
    % Mit hilfe der Dispmap und der relativen Verschiebeung wird die neue x
    % Koordinate für das FreeViewPointBild berechnet
    x_new=round(DispMap1(y,x)*relativeDisp1+x);
    
    % Prüfen ob die neue x Koordinate innerhalb des Bildes liegt
    if x_new>0&&x_new<size(image1,2)
    
        %Übertragen der Farbwerte vom gegebenen Bild in das virtuelle Bild
        Reconstruction(y,x_new,:)=image1(y,x,:);
    end
end
%  figure;
%  imshow(Reconstruction);

for i=1:1:size(image1,1)*size(image1,2)
    
    % ermitteln der x und y Koordinate des Pixels
    [y,x]=ind2sub(size(DispMap2),SortedIndexDispMap2(i));
    
    % Mit hilfe der Dispmap und der relativen Verschiebeung wird die neue x
    % Koordinate für das FreeViewPointBild berechnet
    x_new=round(DispMap2(y,x)*relativeDisp2+x);
    
    % Prüfen ob die neue x Koordinate innerhalb des Bildes liegt
    if x_new>0&&x_new<size(image1,2) && Reconstruction(y,x_new,1)==0&& Reconstruction(y,x_new,2)==0&& Reconstruction(y,x_new,3)==0
        Reconstruction2(y,x_new,:)=image2(y,x,:);
        %Übertragen der Farbwerte vom gegebenen Bild in das virtuelle Bild
        Reconstruction(y,x_new,:)=image2(y,x,:);
    end
end
%  figure;
%  imshow(Reconstruction2)
 end