function output_image=imagewarp(inputIm,H)
% computes inverse warping of inputIm into the plane of refIm and 
% merges both images to give a mergeIm
output_image=zeros(size(inputIm),'uint8');

[r,c,~] = size(inputIm);

tl = H*[1;1;1];
tl = tl/tl(3,1);

tr = H*[c;1;1];
tr= tr/tr(3,1);

bl = H*[1;r;1];
bl = bl/bl(3,1);

br = H*[c;r;1];
br = br/br(3,1);

xmax = max([tl(1,1), tr(1,1), bl(1,1), br(1,1)]);
ymax = max([tl(2,1), tr(2,1), bl(2,1), br(2,1)]);
xmin = min([tl(1,1), tr(1,1), bl(1,1), br(1,1)]);
ymin = min([tl(2,1), tr(2,1), bl(2,1), br(2,1)]);

rangeX = double(uint16(xmax));
rangeY = double(uint16(ymax));

index = 1;
ti = zeros(2,rangeX*rangeY);
for i = 1: rangeX
    for j = 1:rangeY
        ti(1,index) = i;
        ti(2,index) = j;
        index = index + 1;
    end
end

ti = [ti; ones(1, size(ti,2))];
t2 = inv(H)*ti;
t2 = t2./repmat(t2(3,:),[3,1]);
t2 = round(t2);

for i =1:size(t2,2)
    if t2(2,i) > 0 && t2(1,i) > 0 && t2(2,i) <= r && t2(1,i)<=c
        output_image(ti(2,i),ti(1,i),:) = inputIm(t2(2,i),t2(1,i),:);
    end
end
    
    
end

