function show_correspondence(image_l,image_r,correspondence_stable)
 figure; 
 imshow(image_l);
 hold on;
 h = imshow(image_r);      
 alpha=0.5;
 set(h, 'AlphaData', alpha);
 for i=1:size(correspondence_stable,2)
     plot(correspondence_stable(1,i),correspondence_stable(2,i),'r+','MarkerSize',10);
     plot(correspondence_stable(3,i),correspondence_stable(4,i),'b+','MarkerSize',10);
     plot([correspondence_stable(1,i) correspondence_stable(3,i)], [correspondence_stable(2,i) correspondence_stable(4,i)],'g-','MarkerSize',10);
  end
end

