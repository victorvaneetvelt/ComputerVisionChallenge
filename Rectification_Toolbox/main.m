
addpath( genpath('./') );

app = { %'Single view recovery',...
        %'Stitching',...
        %'3D recovery',...
        'Rectification'};
        %'Segmentation',...
        %'Projective depth'};
        
while true
    choice = menu( 'Choose application',app{:}, 'Close');
     switch choice
         case 1
            rectificationGUI
        % case 2
         %    stitching_gui
        % case 3
         %    affine3Dreconstruction_v2
        % case 4
         %    rectificationGUI
        % case 5
        %     objectSegmentation
        % case 6
        %     projectiveDepthGUI
         otherwise
             break;
     end% switch
     
 end% while 1
     