function output_image=postprocessing(image,OriginalImage)

%addieren der einzelnen Farbwerte
image_gray=image(:,:,1)+image(:,:,2)+image(:,:,3);

%berechnung der Amzahl aller noch schwarzen Pixel im Bild
numofzeros=size(image_gray(image_gray(:,:)==0),1);

%berechnung der indizes aller noch schwarzen Pixel
index_zeros=find(~image_gray);

%boolsche pr�fvariable auf falsch setzen 
found=false;

%schleife �ber alle schwarzen Pixel des Bildes
for i=1:1:numofzeros
        
        %berechnung der x und y Koordinaten des schwarzen Pixels
        [y,x]=ind2sub(size(image_gray),index_zeros(i));
        
            %laufvariable in positive x richtung auf 1 setzen
            l=1;
            
            %boolsche pr�fvariable reseten
            found=false;
            
            % schleife die den n�chst gelegenen Pixel sucht, der nicht null
            % ist und noch im Bild liegt
            while x+l<size(image_gray,2)&&found==false
                
                %Pr�fen ob der Pixel den Wert 0 hat
                if image_gray(y,x+l)~=0
                    
                    %wenn er NICHT den Wert 0 hat wird die Pr�fvariable auf wahr gesetzt und so die schlefe beendet 
                    found=true;
                else
                    
                    %wenn der n�chste pixel schwarz ist wird die
                    %Laufvariable inkrementiert
                    l=l+1;
                end
            end
            
            %pr�fen ob der berechnete Pixel im Bild liegt
            if x+l>=size(image_gray,2)
                
                %liegt der berechnete Pixel NICHT im bild, wird die 
                %laufvariable(Entfernung zum n�chsten "nicht 0" Pixel) auf unendlich gesetzt
                l=inf;
            end
            
            %das gleich wird hier nochmal f�r die negative x richtung
            %ausgef�hrt
            k=-1;
            found=false;
            while x+k>0&&found==false
                if image_gray(y,x+k)~=0
                    found=true;
                else
                    k=k-1;
                end
            end
            if x+k<=0
                k=inf;
            end
            
            %suchen des minimalen abstandes zu einem "nicht 0" Pixel in
            %x richtung
            if abs(k)<l
                %�bertragen des Farbwertes des n�chstgelenen "nicht 0" pixels
                image(y,x,:)=image(y,x+k,:);
            else
                image(y,x,:)=image(y,x+l,:);
            end
end
    %Wiederherstellen der Bildoriginalgr��e
    output_image=OriginalImage;
    if size(OriginalImage,1)>size(image,1)||size(OriginalImage,2)>size(image,2)
        sizediff=size(OriginalImage)-size(image);
        output_image(1+floor(sizediff(1)/2):size(OriginalImage,1)-ceil(sizediff(1)/2),1+floor(sizediff(2)/2):size(OriginalImage,2)-ceil(sizediff(2)/2),:)=image;
    end
end