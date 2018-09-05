function output_image=postprocessing(image,OriginalImage)
image_grey=image(:,:,1)+image(:,:,2)+image(:,:,3);
numofzeros=size(image_grey(image_grey(:,:)==0),1);
index_zeros=find(~image_grey);
found=false;
for i=1:1:size(image_grey,2)
    for j=1:1:size(image_grey,1)
        %[y,x]=ind2sub(size(image_grey),index_zeros(i));
        if image_grey(j,i)==0
            l=1;
            found=false;
            while i+l<size(image_grey,2)&&found==false
                if image_grey(j,i+l)~=0
                    found=true;
                else
                    l=l+1;
                end
            end
            if i+l>=size(image_grey,2)
                l=inf;
            end
            k=-1;
            found=false;
            while i+k>0&&found==false
                if image_grey(j,i+k)~=0
                    found=true;
                else
                    k=k-1;
                end
            end
            if i+k<=0
                k=inf;
            end
            if abs(k)<l
                image(j,i,:)=image(j,i+k,:);
            else
                image(j,i,:)=image(j,i+l,:);
            end
        end
    end
    output_image=OriginalImage;
    if size(OriginalImage,1)>size(image,1)||size(OriginalImage,2)>size(image,2)
        sizediff=size(OriginalImage)-size(image);
        output_image(1+floor(sizediff(1)/2):size(OriginalImage,1)-ceil(sizediff(1)/2),1+floor(sizediff(2)/2):size(OriginalImage,2)-ceil(sizediff(2)/2),:)=image;
    end
end