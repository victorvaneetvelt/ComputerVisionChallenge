    %% Stitcher - a class for making a mosaic/stitching images together.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%% methods %%%%%%%%%%%%%%%%%%%%%%%%%
%
% - Stitcher( ['refImage'] )%                   Initializing constructor with optional refImage load.
% - stitch( ['tileImage'] )%                    Perform transformation and overlay tile and ref image, 
%                                               optionally set the tile image in the same action.  
% % getters and setters
% - setRefImage( 'refImage' )
% - setTileImage( 'tileImage' )
% - setPoints( ptNr, coordinate, 'image', ['options'] )%     
%                                               Set the points correlating points of either 'ref' or 'tile',
%                                               the option 'fill' may also be used to load everything at once.
% - getRefImage()%                              Get the panorama image.
% - getTileImage()%                             Get the tile image which may or may not be transformed.
% 
% 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%% properties %%%%%%%%%%%%%%%%%%%%%%%%%
% 
% - refIm%	Reference/panorama image.
% - refSize%	The actual size of the reference image instead of the canvas around it.
% - refPts%	Reference points correlating with the tile image.
% 
% - tileIm%	The image to transform and overlay the reference.
% - tilePts%	Points of the tile image which correlate to the reference points.
% 
% % boolean status variables
% - refOpened
% - tileOpened
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%% Events %%%%%%%%%%%%%%%%%%%%%%%%%
% - noImage             - if an action is attempted while no image is available.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%% Exceptions %%%%%%%%%%%%%%%%%%%%%%%%%
%
% incorrectSize       - Thrown if some specified property (image or point) is too large.



%% class definition
classdef Stitcher < handle
    
    %% Properties
    properties (Access = private)
        refIm%      Reference/panorama image.
        refSize%	The actual size of the reference image instead of the canvas around it.
        refPts%     Reference points correlating with the tile image.
        
        tileIm%     The image to transform and overlay the reference.
        tilePts%	Points of the tile image which correlate to the reference points.
        
        % boolean status variables
        refOpened
        tileOpened
    end% properties (private)
    
    %% methods
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = Stitcher( filename )
            obj.refOpened = false;
            obj.tileOpened = false;
            
            % initialize points
            obj.refPts = zeros( 4, 3 );
            obj.refPts(:,3) = 1;
            obj.tilePts = obj.refPts;
            
            if nargin == 1
                obj.setRefImage( filename )
            end
        end% Stitcher constructor
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setRefImage( obj, filename )
            
            % load image
            if ischar( filename )% from file
                im = imread( filename );
            else% or direct
                im = filename;
            end
            
            % check image size
            [r,c,d] = size( im );
            
            if( r> maxImSize() || c>maxImSize() )
                obj.refOpened = false;
                boundsException = MException('MYFUN:incorrectSize', 'too large image');
                throw( boundsException );
            end
            
            % make canvas
            obj.refIm = uint8( zeros( r*3, c*3,d ) );% make room for up to ~3 images initially
            obj.refIm(1:r,1:c,:) = im;
            
            % store ref size within canvas
            obj.refSize = [ r,c,d ];
            
            obj.refOpened = true;
        end% setRefImage
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setTileImage( obj, filename )
            
            % load image
            if ischar( filename )% from file
                im = imread( filename );
            else% or direct
                im = filename;
            end
            
            % check image size
            [r,c,~] = size( im );
            
            if( r> maxImSize() || c>maxImSize() )
                obj.tileOpened = false;
                boundsException = MException('MYFUN:incorrectSize', 'too large image');
                throw( boundsException );
            end
            
            obj.tileIm = im;
            obj.tileOpened = true;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setPoints( obj, ptNr, coordinate, imageId, options )
           
            % set points based on options
            switch( imageId )
                case 'ref'
                    
                    if ( nargin>4 && strcmp( options, 'fill' ) )% replace matrix
                        obj.refPts = ones( length( coordinate ), 3 );
                        obj.refPts(:,1:2) = coordinate;
                    elseif ( ptNr<=4 && ptNr>0 )% or insert
                        obj.refPts( ptNr, 1:2 ) = coordinate(1:2);
                    end
                    
                case 'tile'
                    
                    if ( nargin>4 && strcmp( options, 'fill' ) )% replace matrix
                        obj.tilePts = ones( length( coordinate ), 3 );
                        obj.tilePts(:,1:2) = coordinate;
                    elseif ( ptNr<=4 && ptNr>0 )% or insert
                        obj.tilePts( ptNr, 1:2 ) = coordinate(1:2);
                    end
                    
                otherwise
                    error( 'ERROR @ setPoints(): Not a valid option' )
            end% switch image
            
        end% setPoints
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function im = getRefImage(obj)
            im = obj.refIm( 1:obj.refSize(1), 1:obj.refSize(2), : );
        end% getRefImage()
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function im = getTileImage(obj)
            im = obj.tileIm;
        end% getTileImage
        
        function [status,inliersOut] = stitch( obj, varargin )
            status = true;
            
            % set image if this option is used ('tile','tileImage')
            if ( nargin>2 && strcmp( varargin{1},'tile' ) )
                obj.setTileImage( varargin{2} );
            end
            
            
            % no point in going further without both images
            if ( ~obj.refOpened || ~obj.tileOpened ) 
                warning( 'ERROR @ stitch(): missing new image' )
                status = false;
                return;
            end
            
            
            % calc homography, offset is foud with respect to ref ([1,1])
            [r, c, ~] = size( obj.tileIm );
            if length(obj.refPts)>4% do inlier detection
                [H, inliersOut] = homography(    obj.refPts, obj.tilePts, 'ransac',...
                                            'threshold',0.1, 'iterations',10000,...
                                            'samplesize',4);
                box = boundingBox( H, [r c] );
                % find the offset
                xmin = min( box(:,1) );
                ymin = min( box(:,2) );

                offset = floor( [ xmin, ymin] );
                
                % reset tile and ref points
                obj.tilePts = ones(4,3);
                obj.refPts = obj.tilePts;
            else
                [H,offset] = homography( obj.refPts, obj.tilePts, [r,c] );
            end
            
            if  (   any(isnan( H(:) ))...
                    || any( abs(offset)>[maxImSize(),maxImSize()] )...
                    || isempty(H) )
                warning('ERROR @ stitch(): No valid homography');
                status = false;
                return;
            end
            
            % apply transformation
            tform = projective2d( H' );
            obj.tileIm = imwarp( obj.tileIm, tform );
            obj.tileOpened = false;% this image is used up
            
            % check the offsets and if negative shift the image accordingly
            [r,c,~] = size( obj.tileIm );
            for i = 1:2
                if offset(i)<1
                    if i == 1% col
                        % shift to the left
                        obj.tileIm = circshift( obj.tileIm, offset(i),2 );
                        % delete the stuff that wrapped around
                        obj.tileIm(:,c+offset(i):c,:) = [];
                    elseif i == 2% row
                        % shift up
                        obj.tileIm = circshift( obj.tileIm, offset(i),1 );
                        % delete the stuff that wrapped around
                        obj.tileIm(r+offset(i):r,:,:) = [];
                    end
                    
                    offset(i) = 1;% rm negative offset
                end% if neg offset
            end% for i
            
            % get the new size
            [r,c,~] = size( obj.tileIm );
            % and find the position to place the transformed image on the canvas
            pos = [   offset(2),offset(2)+r-1;...% row limits
                      offset(1),offset(1)+c-1];% col limits
                  
            % expand canvas if neccessary
            [canvasR, canvasC, canvasD] = size( obj.refIm );
            if pos(1,2)>canvasR
                % add rows
                expansion = uint8( zeros( pos(1,2), canvasC, canvasD ) );
                obj.refIm = [ obj.refIm; expansion ];
                [canvasR, canvasC, canvasD] = size( obj.refIm );% update size
            end
            
            if pos(2,2)>canvasC
                % add columns
                expansion = uint8( zeros( canvasR, pos(2,2), canvasD ) );
                obj.refIm = [ obj.refIm, expansion ];
            end
            
            
            % merge it with the preferred option
            arg = '';
            if( nargin>3 ) 
                arg = varargin{3};
            elseif( nargin == 2 )
                arg = varargin{1};
            end
            
            switch( arg )
                case 'insert'% replace the pixels if>0
                    invalidPixels = (obj.tileIm==0);% find black pixels
                    clip = obj.refIm(1:r,offset(1):offset(1)+c-1,:);
                    obj.tileIm(invalidPixels) = clip( invalidPixels );% replace black with ref pixels
                    obj.refIm( pos(1,1):pos(1,2), pos(2,1):pos(2,2),: ) = obj.tileIm;% insert
                    %%%%%%%%%%%%%%
                otherwise% default is adding in the tile making the overlapping pixels brighter
                    obj.refIm( pos(1,1):pos(1,2), pos(2,1):pos(2,2),: ) = ...
                        obj.refIm( pos(1,1):pos(1,2), pos(2,1):pos(2,2), : ) + obj.tileIm;
            end% switch arg
            
            
                  
            % update image size within canvas
            obj.refSize(1:2) = [ max( obj.refSize(1),pos(1,2) ),max( obj.refSize(2),pos(2,2) )];
            
             
        end% stitch
        
        
    end% methods
    
end% Stitcher class

%% helpers
function n = maxImSize() 
    n = 15000;
end


