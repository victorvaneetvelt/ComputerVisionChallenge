function Pt1=punkte_auf_linie(l2,image1,mind,maxd)
    %Diese Funktion berechnet Pixelkoordinaten, die auf einer Geraden
    %liegen und sich innerhalb eines definierten x-Achsenabschnittes
    %befinden
    
    %Im ersten Abschnitt wird duch die vier if Abfragen ermittelt an welcher
    %der vier Kanten die Gerade in das Bild eintritt und an welcher sie es
    %wieder verlässt. Dabei werden genaue Pixelkoordinaten berechnet.
    x1(1)=1;
    x2(1)=size(image1,2);
    x1(2)=round((-(l2(1)*x1(1)+l2(3))/l2(2)));
    x2(2)=round((-(l2(1)*x2(1)+l2(3))/l2(2)));
    if x1(2)>size(image1,1) || x1(2)<1 || x2(2)>size(image1,1) || x2(2)<1
        if x1(2)>size(image1,1)
            x1(2)=size(image1,1);
            x1(1)=round((-(l2(2)*x1(2)+l2(3))/l2(1)));
        end
        if x1(2)<1
            x1(2)=1;
            x1(1)=round((-(l2(2)*x1(2)+l2(3))/l2(1)));
        end
        
        if x2(2)>size(image1,1)
            x2(2)=size(image1,1);
            x2(1)=round((-(l2(2)*x2(2)+l2(3))/l2(1)));
        end
        if x2(2)<1
            x2(2)=1;
            x2(1)=round((-(l2(2)*x2(2)+l2(3))/l2(1)));
        end
    end
    
    %Ermittlung der Pixelkoordinaten des Start- und Endpixels der Geraden
    %in dem definierten x-Achsenabschnitt 
    Start=max(x1(1),mind);
    End=min(x2(1),maxd);
    
    %Vordefinieren einer Matrix für die Pixelkoordinaten der Geraden
    Pt1=zeros(2,End-(Start-1));
    
    %Schleife vom Start- bis zum Endpixel der Geraden
    for j=Start:1: End 
        
        %Berechnung der Pixelkoordinaten
        %die Formel dafür: x^T*l=0
        %siehe auch Übung Bild Urbild Cobild
        Pt1(:,j)=[j;round(-(l2(1)*j+l2(3))/l2(2))];
    end
    
end