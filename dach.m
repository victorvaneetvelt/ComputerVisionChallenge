function W = dach(w)
    % Diese Funktion implementiert den ^-Operator.
    % Sie wandelt einen 3-Komponenten Vektor in eine
    % schiefsymetrische Matrix um.
    W=[0 -w(3) w(2); w(3) 0 -w(1); -w(2) w(1) 0];
end