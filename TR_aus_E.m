function [T1, R1, T2, R2]=TR_aus_E(E)
    % Diese Funktion berechnet die moeglichen Werte fuer T und R
    % aus der Essentiellen Matrix
    [U,S,V]=svd(E);
    M=[1,0,0;0,1,0;0,0,-1];
    if round(det(U))==-1
        U=U*M;
    end
    if round(det(V))==-1
        V=V*M;
    end
    Rz1=[0,-1,0;1,0,0;0,0,1];
    Rz2=[0,1,0;-1,0,0;0,0,1];
    if round(det(U))==double(1) && round(det(V))==double(1)
        R1=U*Rz1'*V';
        R2=U*Rz2'*V';
        T1temp=U*Rz1*S*U';
        T2temp=U*Rz2*S*U';
        T1=[T1temp(3,2);T1temp(1,3);T1temp(2,1)];
        T2=[T2temp(3,2);T2temp(1,3);T2temp(2,1)];
    end
end