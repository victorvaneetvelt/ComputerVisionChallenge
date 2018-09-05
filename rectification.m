function rectification(left,right,R,T,K)
e1=T;
e2=cross([0;0;1],e1);
e3=-cross(e1,e2);
Rrec=[e1';e2';e3'];

im_left_new=zeros(size(left),'uint8');
im_right_new=zeros(size(left),'uint8');
Kinv=K^-1;
for x=1:1:size(left,2)
    for y=1:1:size(left,1)
        P_neu=Rrec*[x;y;1];
        P_neu=P_neu/P_neu(3);
        P_neu=round(P_neu);
        if P_neu(1)>0&&P_neu(1)<size(left,2)&&P_neu(2)>0&&P_neu(2)<size(left,1)
            im_left_new(P_neu(2),P_neu(1),:)=left(y,x,:);
        end
    end
end
figure(1)
imshow(im_left_new);
    
for x=1:1:size(right,2)
    for y=1:1:size(right,1)
        P_neu=R*Rrec*Kinv*[x;y;1];
        P_neu=P_neu/P_neu(3);
        P_neu=round(K*P_neu);
        if P_neu(1)>0&&P_neu(1)<size(right,2)&&P_neu(2)>0&&P_neu(2)<size(right,1)
            im_right_new(P_neu(2),P_neu(1),:)=right(y,x,:);
        end
        
    end
end
figure(2)
imshow(im_right_new);
end