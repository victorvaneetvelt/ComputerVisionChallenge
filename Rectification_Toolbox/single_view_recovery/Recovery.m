%% Recovery super class
% A parent class for recovery methodes.
% 
% Usage:
%         - Recovery(filePath):                 Constructor which (optionally) imports the image. 
%         - setCorner( cornerNr, coordinate ):  Sets the specified points of a rectangle (pre projection) as [u,v].
%         - getCorners():                       Returns all the setcorners.
%         - recover():                          Initiate recovery.
%         - getRecoveredImage():                Returns a copy of the recovered image if neccessary points are specified.
%         - getImage():                         Returns a copy of the original image.
%         - setImage(filePath):                 Reads the specified image for further use.
% Events:
%         - notRecovered:     Triggers if getRecoveredImage is called without a sucessful recovery.
%         - noImage:          Triggers if recover or getImage is called when no image has been specified.
%% class definition

classdef (Abstract) Recovery < handle
    
    %% properties
    properties (Access = {?AffineRecovery,?MetricRecovery})
        image%          The original image
        corners%        4 corners of a rectangle to be set
        nCorners%       Keeps track of number of corners set
        recovered%      Bool of recovery status
        imageOpened%    Bool of image status
        recoveredImage% The recovered image
    end% properties
    
    
    %% events
    events
        notRecovered
        noImage
    end% events
    
    %% methods
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = Recovery( filePath )% Constructor
            obj.recovered = false;
            obj.corners = zeros(4,3);
            obj.corners(:,3) = 1;
            obj.imageOpened = false;
            
            if nargin > 0
                setImage( filePath );
            end
        end% Recovery
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setCorner( obj, cornerNr, coordinate )
            if cornerNr>0 && cornerNr<=4
                obj.corners( cornerNr, 1:2 ) = coordinate;
            end
        end% setPoint
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function pts = getCorners(obj)
            pts = obj.corners;
        end% getCorners
               
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function im = getRecoveredImage(obj)
            if obj.recovered
                im = obj.recoveredImage;
            else
                notify(obj,'notRecovered');
                im = 0;
            end
        end% getRecoveredImage

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function im = getImage( obj )
            if obj.imageOpened
                im = obj.image;
            else
                notify( obj, 'noImage' );
                im = 0;
            end
        end% getImage
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setImage( obj, filePath )
            try
                obj.image = imread( filePath );
                obj.imageOpened = true;
            catch
                notify(obj, 'noImage' );
                obj.imageOpened = false;
            end
        end% setImage
        
    end% methods
    
    %% abstract methods
    methods (Abstract)
        recover(obj)
    end% abstract methods
    
  
    
end% Recovery