function [EF] = achtpunktalgorithmus(Korrespondenzen, K)
    % Diese Funktion berechnet die Essentielle Matrix oder Fundamentalmatrix
    % mittels 8-Punkt-Algorithmus, je nachdem, ob die Kalibrierungsmatrix 'K'
    % vorliegt oder nicht
    hom=ones(1,size(Korrespondenzen,2));
    x1=[Korrespondenzen(1,:);Korrespondenzen(2,:);hom(1,:)];
    x2=[Korrespondenzen(3,:);Korrespondenzen(4,:);hom(1,:)];
    if nargin ==2
        x1=K^-1*x1;
        x2=K^-1*x2;
    end
    A=zeros(size(x1,2),size(x1,1)*size(x2,1));
    for i=1:1:size(x1,2)
        A(i,:)=kron(x1(:,i),x2(:,i));
    end
    [~,~,V]=svd(A);
    Gs=V(:,end);
    G=[Gs(1:3),Gs(4:6),Gs(7:9)];
    [u,s,v]=svd(G);
    if nargin ==2
        s=zeros(3,3);
        s(1,1)=1;
        s(2,2)=1;
        EF = u*s*v'; %Essenzielle Matrix
    else
        s(3,3)=0;
        EF = u*s*v'; %Fundamentalmatrix
    end
end