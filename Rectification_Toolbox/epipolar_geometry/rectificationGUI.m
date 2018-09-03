function varargout = rectificationGUI(varargin)
% RECTIFICATIONGUI MATLAB code for rectificationGUI.fig
%      RECTIFICATIONGUI, by itself, creates a new RECTIFICATIONGUI or raises the existing
%      singleton*.
%
%      H = RECTIFICATIONGUI returns the handle to a new RECTIFICATIONGUI or the handle to
%      the existing singleton*.
%
%      RECTIFICATIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RECTIFICATIONGUI.M with the given input arguments.
%
%      RECTIFICATIONGUI('Property','Value',...) creates a new RECTIFICATIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rectificationGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rectificationGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help rectificationGUI

% Last Modified by GUIDE v2.5 03-Sep-2018 10:54:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rectificationGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @rectificationGUI_OutputFcn, ...
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


% --- Executes just before rectificationGUI is made visible.
function rectificationGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rectificationGUI (see VARARGIN)

% Choose default command line output for rectificationGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes rectificationGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.im1 = imread( './images/L1.JPG' );
handles.im2 = imread( './images/R1.JPG' );

setImages( hObject, handles );


% --- Outputs from this function are returned to the command line.
function varargout = rectificationGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in openButton.
function openButton_Callback(hObject, eventdata, handles)
% hObject    handle to openButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [file,path] = uigetfile({'*.jpg;*.JPEG;*.PNG;*.png'}, 'Multiselect', 'on');
    
    if length(file)==2
        handles.im1 = imread( strcat(path,file{1}) );
        handles.im2 = imread( strcat(path,file{2}) );
        
        % Update handles structure
        guidata(hObject, handles);
        
        setImages( hObject, handles );
    else
        disp('Try again, pick 2 images');
    end



% --- Executes on button press in closeButton.
function closeButton_Callback(hObject, eventdata, handles)
% hObject    handle to closeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    close(gcf)

% --- Executes on button press in anaglyphButton.
function anaglyphButton_Callback(hObject, eventdata, handles)
% hObject    handle to anaglyphButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    if handles.r.rectStatus
        figure,imshow(stereoAnaglyph(handles.r.rectIm1,handles.r.rectIm2));
        diff = abs( handles.r.in1(:,1) - handles.r.in2(:,1) );
        [~,idx] = max( diff );% largest difference in x-direction between 2 inliers
        hold on% plot inliers
        plot( handles.r.in1(:,1),handles.r.in1(:,2),'ro');
        plot( handles.r.in2(:,1),handles.r.in2(:,2),'co');
        % mark the greatest difference in x-direction
        plot( handles.r.in1(idx,1),handles.r.in1(idx,2),'go','MarkerFaceColor','r');
        plot( handles.r.in2(idx,1),handles.r.in2(idx,2),'go','MarkerFaceColor','c');
        plot(   [handles.r.in1(idx,1), handles.r.in2(idx,1)],...
                [handles.r.in1(idx,2), handles.r.in2(idx,2)],'LineWidth',2,'Color','g' );
        hold off
    else
        disp('Need a valid rectification first');
    end% if rectStatus


% --- Executes on button press in disparityButton.
function disparityButton_Callback(hObject, eventdata, handles)
% hObject    handle to disparityButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [disparityMap, disparityRange] = handles.r.calcDisparity();
    figure,imshow( disparityMap, disparityRange );
    colormap jet
    colorbar
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%TESTING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     save( 'disparityValues', 'disparityMap', 'disparityRange');
%     imwrite( handles.r.rectIm1, 'rectifiedImage1.png');
%     imwrite( handles.r.rectIm2, 'rectifiedImage2.png');

%---
function setImages( hObject, handles )

    for i=1:10% try until good rectification (or count)
        fprintf('Rectifying, trial %d\n',i)
        [handles.r, success] = Rectify( handles.im1, handles.im2 );

        if success
            break;
        end

    end
    
    % set pre rectification images 
    
    % image 1
    axes( handles.axesIm1 );
    cla reset;
    imshow( handles.im1 );
    
    hold on
    handles.r.epi.plotInlierFeatures(1,8);% plot 8 inliers in image 1
    handles.r.epi.plotEpiLine(1,8);
    hold off

    % image 2
    axes( handles.axesIm2 );
    cla reset;
    imshow( handles.im2 );
    
    hold on
    handles.r.epi.plotInlierFeatures(2,8);% plot 10 inliers in image 2
    handles.r.epi.plotEpiLine(2,8);
    hold off
    
    
    if ~success  
        choice = questdlg(  'Could not rectify', ...
                            'Failed rectification',...
                            'Retry', ...
                            'Close','Retry');
        if strcmp(choice,'Retry')
            setImages( hObject, handles );
        end
        return;
    end
    
    % a little cheat.. transforming inliers and F with the found
    % rectfication homographies and replace
    handles.r.epi.in1 = handles.r.in1;
    handles.r.epi.in2 = handles.r.in2;
    handles.r.epi.F = ( handles.r.H2'\handles.r.epi.F)/handles.r.H1;
    handles.r.epi.im1 = handles.r.rectIm1;
    handles.r.epi.im2 = handles.r.rectIm2;
    
    handles.r.epi.calcEpiLines();
    
    % set rectified images 
    
    % image 1
    axes( handles.axesRectIm1 );
    cla reset;
    imshow( handles.r.rectIm1 );
    Rectification_image1=handles.r.rectIm1;
    save('rect_im1.mat','Rectification_image1');
    hold on
    handles.r.epi.plotInlierFeatures(1,8);% plot 8 inliers in image 1
    handles.r.epi.plotEpiLine(1,8);
    hold off

    % image 2
    axes( handles.axesRectIm2 );
    cla reset;
    imshow( handles.r.rectIm2 );
    Rectification_image2=handles.r.rectIm2;
    save('rect_im2.mat','Rectification_image2');
    hold on
    handles.r.epi.plotInlierFeatures(2,8);% plot 10 inliers in image 2
    handles.r.epi.plotEpiLine(2,8);
    hold off
    
    % Update handles structure
    guidata(hObject, handles);


% --- Executes on button press in retryButton.
function retryButton_Callback(hObject, eventdata, handles)
% hObject    handle to retryButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    setImages(hObject,handles);
