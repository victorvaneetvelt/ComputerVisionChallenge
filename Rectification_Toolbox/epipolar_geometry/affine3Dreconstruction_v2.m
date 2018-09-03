% Affine 3D reconstruction

%% config
showVanishingPts = false;
showSq = [true true true];

%% control points (hand picked)

cp1 = [...
        0.9170    0.3084;...
        1.3005    0.0966;...
        %1.2730    0.6676;...
        1.2804    0.6716;...% test
        0.9711    1.0655;...
        0.4642    0.8986;...
        0.3142    0.2356;...
        0.8440    0.0716]*1000;
cp2 = [...  
        0.6310    0.2986;...
        1.1399    0.0868;...
        %1.1375    0.6524;...
        1.1480    0.6551;...%test
        0.7470    1.0344;...
        0.3067    0.8557;...
        0.1247    0.2220;...
        0.7157    0.0561]*1000;


%% load images
im1 = imread('images/drawer1.png');
im2 = imread('images/drawer2.png');


%% estimate the fundamental matrix and triangulate
epi = Epipolar(im1,im2);

%% find vanishing points from control points
cp1 = [ cp1, ones(length(cp1),1) ];
cp2 = [ cp2, ones(length(cp2),1) ];

% parallel lines im1
L1 = cross( cp1(1,:)',cp1(2,:)' );
L2 = cross( cp1(6,:)',cp1(7,:)' );
L3 = cross( cp1(1,:)',cp1(4,:)' );
L4 = cross( cp1(5,:)',cp1(6,:)' );
L5 = cross( cp1(5,:)',cp1(4,:)' );
L6 = cross( cp1(1,:)',cp1(6,:)' );
% vanishing points im1
v1 = zeros(3,3);
v1(1,:) = ( cross( L1,L2 ) )'; v1(1,:) = v1(1,:)./v1(1,3);
v1(2,:) = ( cross( L3,L4 ) )'; v1(2,:) = v1(2,:)./v1(2,3);
v1(3,:) = ( cross( L5,L6 ) )'; v1(3,:) = v1(3,:)./v1(3,3);

% parallel lines im2
L2 = cross( cp2(6,:)',cp2(7,:)' );
L4 = cross( cp2(5,:)',cp2(6,:)' );
L5 = cross( cp2(4,:)',cp2(5,:)' );
% vanishing points im2 compatible with the epipolar line from v1
v2 = zeros(3,3);
v2(1,:) = ( cross( L2,epi.F*v1(1,:)' ) )'; v2(1,:) = v2(1,:)./v2(1,3);
v2(2,:) = ( cross( L4,epi.F*v1(2,:)' ) )'; v2(2,:) = v2(2,:)./v2(2,3);
v2(3,:) = ( cross( L5,epi.F*v1(3,:)' ) )'; v2(3,:) = v2(3,:)./v2(3,3);



%% triangulate
epi.in1 = [ cp1;v1 ];
epi.in2 = [ cp2;v2 ];

worldPts = epi.triangulate('optimal');

worldPts = [ worldPts, ones( length(worldPts),1) ];% make homogeneous


%% show image with controlpoints
color = [   1   1   0;...
            1   0   1;...
            0   1   1;...
            1   0   0;...
            0   1   0;...
            0   0   1;...
            1   1   1;...
            0   0   0];
        
figure,subplot(2,2,[1 2]);
imshow(im1);
hold on
sq1 = [ 1,2,3,4 ];
sq2 = [ 1,6,7,2 ];
sq3 = [ 1,4,5,6 ];
if showSq(1)
    plot2DShape( cp1(sq1,1:2), color(sq1,:) );
end
if showSq(2)
    plot2DShape( cp1(sq2,1:2), color(sq2,:) );
end
if showSq(3)
    plot2DShape( cp1(sq3,1:2), color(sq3,:) );
end
hold off

%% show projective reconstruction (triangulation)
subplot(2,2,3);
title('Projective reconstruction');
hold on
if showSq(1)
    plot3DShape( worldPts(sq1,1:3), color(sq1,:) );
end
if showSq(2)
    plot3DShape( worldPts(sq2,1:3), color(sq2,:) );
end
if showSq(3)
    plot3DShape( worldPts(sq3,1:3), color(sq3,:) );
end


if showVanishingPts
    if showSq(2)
        plotVanishingPt( worldPts(end-2,:), [worldPts(2,1:3);worldPts(7,1:3)], 'r+' );% 1
    end
    if showSq(3)
        plotVanishingPt( worldPts(end-1,:), [worldPts(1,1:3);worldPts(6,1:3)], 'g+' );% 2
        plotVanishingPt( worldPts(end,:), [worldPts(5,1:3);worldPts(6,1:3)], 'b+' );% 3
    end
end
hold off

%% Reconstruct Affine properties
worldPts = epi.triangulateAffine( v1, v2 );

%% show reconstructed results

subplot(2,2,4);
title('Affine reconstruction');
hold on
if showSq(1)
    plot3DShape( worldPts(sq1,1:3), color(sq1,:) ); 
end
if showSq(2)
    plot3DShape( worldPts(sq2,1:3), color(sq2,:) );
end
if showSq(3)
    plot3DShape( worldPts(sq3,1:3), color(sq3,:) );
end
hold off




%% functions
function plot2DShape( data, color )
    % sides
    plot( [data(:,1);data(1,1)],[data(:,2);data(1,2)],'g','LineWidth',2 );     
    % verticies
    scatter( data(:,1), data(:,2), [],color,'filled' );
end

function plot3DShape( data, color )
    % sides
    plot3( [data(:,1);data(1,1)],[data(:,2);data(1,2)],[data(:,3);data(1,3)],...
        'g','LineWidth',2 );
    % verticies
    scatter3( data(:,1), data(:,2), data(:,3), 30,color,'o','filled','MarkerEdgeColor','r');
end

function plotVanishingPt( pt, origins, marker )
    
    % points
    scatter3( pt(:,1), pt(:,2), pt(:,3), marker);
    % lines
    plot3(  [origins(1,1); pt(:,1); origins(2,1)],...
            [origins(1,2); pt(:,2); origins(2,2)],...
            [origins(1,3); pt(:,3); origins(2,3)],'--' );
   
end

