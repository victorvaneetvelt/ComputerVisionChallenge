function varargout = projectiveDepthGUI(varargin)
% PROJECTIVEDEPTHGUI MATLAB code for projectiveDepthGUI.fig
%      PROJECTIVEDEPTHGUI, by itself, creates a new PROJECTIVEDEPTHGUI or raises the existing
%      singleton*.
%
%      H = PROJECTIVEDEPTHGUI returns the handle to a new PROJECTIVEDEPTHGUI or the handle to
%      the existing singleton*.
%
%      PROJECTIVEDEPTHGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROJECTIVEDEPTHGUI.M with the given input arguments.
%
%      PROJECTIVEDEPTHGUI('Property','Value',...) creates a new PROJECTIVEDEPTHGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before projectiveDepthGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to projectiveDepthGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help projectiveDepthGUI

% Last Modified by GUIDE v2.5 26-Jul-2017 08:42:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @projectiveDepthGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @projectiveDepthGUI_OutputFcn, ...
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


% --- Executes just before projectiveDepthGUI is made visible.
function projectiveDepthGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to projectiveDepthGUI (see VARARGIN)

% Choose default command line output for projectiveDepthGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes projectiveDepthGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 % initial image
 file1 = 'building1a.jpg';
 file2 = 'building2a.jpg';
 path = '';
openButton_Callback(hObject, eventdata, handles, file1, file2, path);



% --- Outputs from this function are returned to the command line.
function varargout = projectiveDepthGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in openButton.
function openButton_Callback(hObject, eventdata, handles, varargin)
% hObject    handle to openButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    if length(varargin) == 3
        file = cell(2,1);
        file{1} = varargin{1};
        file{2} = varargin{2};
        path = varargin{3};
    else
        [file,path] = uigetfile({'*.jpg;*.JPEG;*.PNG;*.png'}, 'Multiselect', 'on');
    end

    if length(file)==2
        im1 = imread( strcat(path,file{1}) );
        im2 = imread( strcat(path,file{2}) );

        % estimate fundamental matrix
        handles.epi = Epipolar( im1, im2 );
       
        % Update handles structure
        guidata(hObject, handles);

   
        axes( handles.axes1 );
        cla reset% clear axes
        imshow( im1 );
        drawnow
        
%         h = msgbox('Please wait..');
%         handles.epi.correctInliers();
%         delete(h);
        % Update handles structure
        guidata(hObject, handles);
        
        addPoints(hObject);
        
        
    else
        msgbox('Please select 2 images');

    end% if



% --- Executes on button press in closeButton.
function closeButton_Callback(hObject, eventdata, handles)
% hObject    handle to closeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    close(gcf);
    
% ---
function addPoints( hObject )
    handles = guidata( hObject );
    
    axes( handles.axes1 );

    handles.selectedPts = zeros(3,1, 'int32');
    handles.selectedPtsIdx = 1;
    
    len = length( handles.epi.in1 );
    handles.pts = cell(len,1);
    
    hold on
    for i = 1:len
        % make a handle for each point
        handles.pts{i} = plot( handles.epi.in1(i,1), handles.epi.in1(i,2),...
                                'wo', 'MarkerFaceColor', 'red',...
                                'HitTest','on');
    end% for
    
    % after handles.pts is filled attach a callback function
    for i = 1:len
        handles.pts{i}.ButtonDownFcn ={@ptCallback,i};
    end
    
    hold off
    
     % Update handles structure
     guidata(hObject, handles);
  
% ---
function ptCallback( hObject, eventdata, ptNr )
%     fprintf('Clicked %d\n', ptNr );
    handles = guidata(hObject);
    
    % check uniqueness
    if ~any( handles.selectedPts == ptNr )
        
        handles.pts{ptNr}.MarkerFaceColor = 'cyan';
        handles.selectedPts( handles.selectedPtsIdx ) = ptNr;
        
        handles.selectedPtsIdx = handles.selectedPtsIdx + 1;
        if handles.selectedPtsIdx>3
            handles.selectedPtsIdx = 1;
        end
        
        
        % perform binary space partitioning if 3 points are selected
        if ~any( handles.selectedPts==0 )
            spacePartition( hObject, handles );
        end
                
        % Update handles structure
        guidata(hObject, handles);
        
    end% if unique
        
    
% ---
function spacePartition( hObject, handles )

%for testing
len = length( handles.epi.in1 );
handles.epi.in1 = [ handles.epi.in1(:,1:2) ones( len, 1) ];
handles.epi.in2 = [ handles.epi.in2(:,1:2) ones( len, 1) ];

    v1 = handles.epi.in1( handles.selectedPts, : );
    v2 = handles.epi.in2( handles.selectedPts, : );
    
    
    H = plane2Homography( v1,v2, handles.epi.F, handles.epi.eP2 );

    % calculate projective depth for each point
    for i=1:length( handles.epi.in1 )
        
        if any( handles.selectedPts == i )
            continue;
        end
        
        trans = (H*handles.epi.in1(i,:)')';
        trans = trans./trans(3);
        pDepth = (handles.epi.in2(i,:)-trans)*handles.epi.eP2;

        if pDepth<0
            handles.pts{i}.MarkerFaceColor = 'red';
        else
            handles.pts{i}.MarkerFaceColor = 'green';
        end

    end% for i
    
    % Update handles structure
     guidata(hObject, handles);
        
