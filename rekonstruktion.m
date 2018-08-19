function [T, R, lambda, Gamma] = rekonstruktion(T1, T2, R1, R2, Korrespondenzen, K, varargin)
    %% Preparation
    p=inputParser;
    addOptional(p,'do_plot',false, @(x) islogical(x));
    p.parse(varargin{:});
    do_plot=p.Results.do_plot;
    
    T_cell={T1,T2,T1,T2};
    R_cell={R1,R1,R2,R2};
    vec_ones=ones(1,size(Korrespondenzen,2));
    x1=[Korrespondenzen(1,:);Korrespondenzen(2,:);vec_ones];
    x2=[Korrespondenzen(3,:);Korrespondenzen(4,:);vec_ones];
    x1=K^-1*x1;
    x2=K^-1*x2;
    d=zeros(size(Korrespondenzen,2),2);
    d_cell={d,d,d,d};
    Gamma=0;
    Gamma_cell={Gamma,Gamma,Gamma,Gamma};
    %% Gleichungssystem
    for i=1:1:4
        M1=zeros(size(Korrespondenzen,2)*3,size(Korrespondenzen,2)+1);
        M2=zeros(size(Korrespondenzen,2)*3,size(Korrespondenzen,2)+1);
        for j=1:1:size(Korrespondenzen,2)
            M1(3*j-2:3*j,j)=dach(x2(:,j))*R_cell{i}*x1(:,j);
            M1(3*j-2:3*j,end)=dach(x2(:,j))*T_cell{i};
            M2(3*j-2:3*j,j)=dach(x1(:,j))*R_cell{i}'*x2(:,j);
            M2(3*j-2:3*j,end)=-dach(x1(:,j))*R_cell{i}'*T_cell{i};
        end
        [~,~,v]=svd(M1);
        d1=v(:,end);
        [~,~,v]=svd(M2);
        d2=v(:,end);
        Gamma_cell{i}=(abs(d1(end,end))+abs(d2(end,end)))/2;% Hier Mittelwert bilden, falls die Gammas kleine Unterschiede haben um dadurch die Genauigkeit zu erhöhen. 
        d1=d1/d1(end,end);
        d2=d2/d2(end,end);
        d_cell{i}=[d1(1:end-1),d2(1:end-1)]; %Hier wird der Gammawert aus dem Lambdavektor gelöscht
     end
    a=zeros(4,1);
    a(1)=size(d_cell{1}(d_cell{1}>=0),1);
    a(2)=size(d_cell{2}(d_cell{2}>=0),1);
    a(3)=size(d_cell{3}(d_cell{3}>=0),1);
    a(4)=size(d_cell{4}(d_cell{4}>=0),1);
    [~,index]=max(a(:));
    T=T_cell{index};
    R=R_cell{index};
    lambda=d_cell{index};
    Gamma=Gamma_cell{index};
    
    %% Darstellung
    if do_plot==true
        P1=zeros(size(x1));
        for i=1:1:size(x1,2)
            P1(:,i)=lambda(i,1)*x1(:,i);
        end
        str_num=string(1:1:size(x1,2));
        camC1=[-0.2,0.2,0.2 ,-0.2;
                0.2,0.2,-0.2,-0.2;
                1  ,1  ,1   ,1];
        camC2=R^-1*camC1-R^-1*T;
        scatter3(P1(1,:),P1(2,:),P1(3,:));
        hold on
        text(P1(1,:),P1(2,:),P1(3,:),str_num);
        plot3([camC1(1,:),camC1(1,1)],[camC1(2,:),camC1(2,1)],[camC1(3,:),camC1(3,1)],'b');
        plot3([camC2(1,:),camC2(1,1)],[camC2(2,:),camC2(2,1)],[camC2(3,:),camC2(3,1)],'r');
        text(camC1(1,3),camC1(2,3),camC1(3,3),'camC1');
        text(camC2(1,3),camC2(2,3),camC2(3,3),'camC2');
        campos([43;-22;-87]);
        camup([0;-1;0]);
        xlabel('X');
        ylabel('Y');
        zlabel('Z');
        grid on;
        hold off
    end
end