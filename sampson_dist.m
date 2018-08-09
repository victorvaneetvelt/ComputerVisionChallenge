function sd = sampson_dist(F, x1_pixel, x2_pixel)
    % Diese Funktion berechnet die Sampson Distanz basierend auf der
    % Fundamentalmatrix F
    e_dach=[0,-1,0;1,0,0;0,0,0];
    sd=ones(1,size(x1_pixel,2))*(((x2_pixel'*F*x1_pixel).*eye(size(x1_pixel,2))).^2); %berechnung des Zählers        die Werte des Zählers liegen auf der Diagonalen der n x n Matrix, die sich aus x2_pixel'*F*x1_pixel ergibt
    dnom=vecnorm(e_dach*F*x1_pixel).^2+vecnorm((x2_pixel'*F*e_dach)').^2;            %berechnung des Nenners

    sd=sd./dnom;
end