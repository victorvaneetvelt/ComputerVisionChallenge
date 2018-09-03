function varargout = stitching_gui(varargin)
% STITCHING_GUI MATLAB code for stitching_gui.fig
%      STITCHING_GUI, by itself, creates a new STITCHING_GUI or raises the existing
%      singleton*.
%
%      H = STITCHING_GUI returns the handle to a new STITCHING_GUI or the handle to
%      the existing singleton*.
%
%      STITCHING_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STITCHING_GUI.M with the given input arguments.
%
%      STITCHING_GUI('Property','Value',...) creates a new STITCHING_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before stitching_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to stitching_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help stitching_gui

% Last Modified by GUIDE v2.5 22-Jun-2017 09:20:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stitching_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @stitching_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before stitching_gui is made visible.
function stitching_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to stitching_gui (see VARARGIN)

% Choose default command line output for stitching_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes stitching_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% make objects to use throughout gui
handles.stitcher = Stitcher('images/book1a.jpg');
handles.stitcher.setTileImage('images/book2a.jpg');
handles.refIm = handles.stitcher.getRefImage();
handles.tileIm = handles.stitcher.getTileImage();

% display the images
dispImages( hObject, handles );

% set up dragpoints
configRefPts( hObject, handles );
configTilePts( hObject, handles );


% --- Outputs from this function are returned to the command line.
function varargout = stitching_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in setRefButton.
function setRefButton_Callback(hObject, eventdata, handles)
% hObject    handle to setRefButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [file,path] = uigetfile({'*.jpg;*.JPEG;*.PNG;*.png'});
    if file ~= 0
        handles.stitcher.setRefImage(strcat(path,file));
        handles.refIm = handles.stitcher.getRefImage(); 

        axes( handles.refAxes );
        cla reset% clear axes
        imshow( handles.stitcher.getRefImage() );
        configRefPts( hObject, handles );
        
        
        % Update handles structure
        guidata(hObject, handles);

    end% if



% --- Executes on button press in setTileButton.
function setTileButton_Callback(hObject, eventdata, handles)
% hObject    handle to setTileButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [file,path] = uigetfile({'*.jpg;*.JPEG;*.PNG;*.png'});
    if file ~= 0
        handles.stitcher.setTileImage(strcat(path,file));
        handles.tileIm = handles.stitcher.getTileImage();

        axes( handles.tileAxes );
        cla reset% clear axes
        imshow( handles.stitcher.getTileImage() );
        configTilePts( hObject, handles );
        
        % Update handles structure
        guidata(hObject, handles);

    end% if


% --- Executes on button press in stitchButton.
function stitchButton_Callback(hObject, eventdata, handles)
% hObject    handle to stitchButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % indicate wating
    set(handles.figure1, 'pointer', 'watch')
    drawnow;
    
    if get( handles.resCheckbox, 'Value' )% check if high res is set
        valid = handles.stitcher.stitch('tile', handles.tileIm, 'insert');
    else
        valid = handles.stitcher.stitch('tile', handles.tileIm);
    end
    set(handles.figure1, 'pointer', 'arrow')
    
    if valid
        %handles.refIm = handles.stitcher.getRefImage();
        axes( handles.refAxes );
        cla reset% clear axes
        imshow( handles.stitcher.getRefImage() );
        configRefPts( hObject, handles );
    else
        msgbox('Could not estimate homography');
    end
        
    
    % Update handles structure
    guidata(hObject, handles);
    
    
    


% --- Executes on button press in resCheckbox.
function resCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to resCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of resCheckbox

% ---
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dispImages(hObject, handles)
    % ref
    axes( handles.refAxes );
    cla reset;
    axis image
    cla reset;
    imshow( handles.refIm );
    % tile
    axes( handles.tileAxes );
    cla reset;
    axis image
    imshow( handles.tileIm );
    
% ---
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function configRefPts( hObject, handles )
    
    % limit the movement of points
    % ref
    xlimRef = get(handles.refAxes,'XLim');
    ylimRef = get(handles.refAxes,'YLim');
    refPts = [   xlimRef(2)/4,ylimRef(2)/4;...
                        xlimRef(2)*3/4,ylimRef(2)/4;...
                        xlimRef(2)*3/4,ylimRef(2)*3/4;...
                        xlimRef(2)/4,ylimRef(2)*3/4];
    % colors
    color = [ 'r','g','b','y' ];

    for i = 1:4

    % make custom call for each corner with an index and handle passing
    ptFncRef = @(pos) newCornerPos(hObject, handles,pos,i, 'ref');
    
    % make points
    refHandle = impoint(handles.refAxes,refPts(i,:));
    
    % store the initial positions
    handles.stitcher.setPoints(i,refPts(i,:),'ref');
    
    % link movement of a corner to function
    addNewPositionCallback(refHandle,ptFncRef);  
    
    % Construct boundary constraint function
    fcnRef = makeConstrainToRectFcn('impoint',xlimRef,ylimRef);
    
    % Enforce boundary constraint function
    setPositionConstraintFcn(refHandle,fcnRef);
    
    % set colors
    setColor( refHandle, color(i) );
    
    end% for
    
    % Update handles structure
    guidata(hObject, handles);
   
    
% ---
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function configTilePts( hObject, handles )
    
    % limit the movement of points
    % tile
    xlimTile = get(handles.tileAxes,'XLim');
    ylimTile = get(handles.tileAxes,'YLim');
    tilePts = [   xlimTile(2)/4,ylimTile(2)/4;...
                        xlimTile(2)*3/4,ylimTile(2)/4;...
                        xlimTile(2)*3/4,ylimTile(2)*3/4;...
                        xlimTile(2)/4,ylimTile(2)*3/4];
    % colors
    color = [ 'r','g','b','y' ];

    for i = 1:4

    % make custom call for each corner with an index and handle passing
    ptFncTile = @(pos) newCornerPos(hObject, handles,pos,i, 'tile');

    % make points
    tileHandle = impoint(handles.tileAxes,tilePts(i,:));
    
    % store the initial positions
    handles.stitcher.setPoints(i,tilePts(i,:),'tile');
    
    % link movement of a corner to function
    addNewPositionCallback(tileHandle,ptFncTile);
    
    % Construct boundary constraint function
    fcnTile = makeConstrainToRectFcn('impoint',xlimTile,ylimTile);
    
    % Enforce boundary constraint function
    setPositionConstraintFcn(tileHandle,fcnTile);
    
    % set colors
    setColor( tileHandle, color(i) );
    
    end% for
    
    % Update handles structure
    guidata(hObject, handles);    
    
    
% --- executes everytime a corner moves
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function newCornerPos(hObject, handles, pos, pt, im)
    %fprintf('Corner %.f moved to [ %.2f, %.2f ]\n',pt,pos(1),pos(2));
    
    handles.stitcher.setPoints( pt, pos, im );
    
    % Update handles structure
    guidata(hObject, handles);


% --- Executes on button press in autoStitchButton.
function autoStitchButton_Callback(hObject, eventdata, handles)
% hObject    handle to autoStitchButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    im1 = rgb2gray( handles.stitcher.getRefImage() );
    im2 = rgb2gray( handles.stitcher.getTileImage() );
    
    % detect
    pt1 = detectSURFFeatures( im1 );
    pt2 = detectSURFFeatures( im2 );
    % extract
    [ft1, validPt1] = extractFeatures( im1, pt1 );
    [ft2, validPt2] = extractFeatures( im2, pt2 );
    % find common features
    sharedIndex = matchFeatures( ft1, ft2 );
    mtchPt1 = validPt1( sharedIndex(:,1), : );
    mtchPt2 = validPt2( sharedIndex(:,2), : );
    
    n = length(sharedIndex);% nr of features to use
    if get( handles.show_features_checkbox, 'Value' )% check if matching features is displayed
        figure, showMatchedFeatures( im1, im2, mtchPt1(1:n), mtchPt2( 1:n ) );
    end

    refPt = mtchPt1( 1:n ).Location;
    tilePt = mtchPt2( 1:n ).Location;


    handles.stitcher.setPoints( 1, refPt, 'ref', 'fill' );
    handles.stitcher.setPoints( 1, tilePt, 'tile', 'fill' );

    stitchButton_Callback(hObject, eventdata, handles);
    
    % Update handles structure
    guidata(hObject, handles);


% --- Executes on button press in reset_button.
function reset_button_Callback(hObject, eventdata, handles)
% hObject    handle to reset_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % display the images
    dispImages( hObject, handles );

    % set up dragpoints
    configRefPts( hObject, handles );
    configTilePts( hObject, handles );
    
    handles.stitcher.setRefImage( handles.refIm );
    handles.stitcher.setTileImage( handles.tileIm );
    % Update handles structure
    guidata(hObject, handles);


% --- Executes on button press in show_features_checkbox.
function show_features_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to show_features_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of show_features_checkbox
