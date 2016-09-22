function varargout = botao1(varargin)
% BOTAO1 MATLAB code for botao1.fig
%      BOTAO1, by itself, creates a new BOTAO1 or raises the existing
%      singleton*.
%
%      H = BOTAO1 returns the handle to a new BOTAO1 or the handle to
%      the existing singleton*.
%
%      BOTAO1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BOTAO1.M with the given input arguments.
%
%      BOTAO1('Property','Value',...) creates a new BOTAO1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before botao1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to botao1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help botao1

% Last Modified by GUIDE v2.5 09-Nov-2013 17:20:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @botao1_OpeningFcn, ...
                   'gui_OutputFcn',  @botao1_OutputFcn, ...
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


% --- Executes just before botao1 is made visible.
function botao1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to botao1 (see VARARGIN)

% Choose default command line output for botao1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes botao1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = botao1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton1.
function pushbutton1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on key press with focus on pushbutton1 and none of its controls.
function pushbutton1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function pushbutton1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
thresh = 0.8; % Threshold for white detection

vidDevice = imaq.VideoDevice('winvideo', 1, 'YUY2_640x480', ... % Acquire input video stream
 'ROI', [1 1 640 480], ...
 'ReturnedColorSpace', 'rgb');
vidInfo = imaqhwinfo(vidDevice); % Acquire input video property
hblob = vision.BlobAnalysis('AreaOutputPort', false, ... % Set blob analysis handling
 'CentroidOutputPort', true, ... 
 'BoundingBoxOutputPort', true', ...
 'MinimumBlobArea', 800, ...
 'MaximumCount', 10);
hshapeinsWhiteBox = vision.ShapeInserter('BorderColor', 'White'); % Set white box handling
htextins = vision.TextInserter('Text', 'Number of White Object(s): %2d', ... % Set text for number of blobs
 'Location', [7 2], ...
  'Color', [1 1 1], ... // white color
 'Font', 'Courier New', ...
 'FontSize', 12);
htextinsCent = vision.TextInserter('Text', ' X:%6.2f, Y:%6.2f', ... % set text for centroid
 'LocationSource', 'Input port', ...
 'Color', [0 0 0], ... // black color
 'FontSize', 12);   
hVideoIn = vision.VideoPlayer('Name', 'Final Video', ... % Output video player
 'Position', [100 100 vidInfo.MaxWidth+20 vidInfo.MaxHeight+30]);
nFrame = 0; % Frame number initialization
fwrite(d,'c');
%% Processing Loop
while(nFrame < 150)
 rgbFrame = step(vidDevice); % Acquire single frame
% rgbFrame = flipdim(rgbFrame,2); % obtain the mirror image for displaying

bwredFrame = im2bw(rgbFrame(:,:,1), thresh); % obtain the white component from red layer
 bwgreenFrame = im2bw(rgbFrame(:,:,2), thresh); % obtain the white component from green layer
 bwblueFrame = im2bw(rgbFrame(:,:,3), thresh); % obtain the white component from blue layer
 binFrame = bwredFrame & bwgreenFrame & bwblueFrame; % get the common region
 binFrame = medfilt2(binFrame, [3 3]); % Filter out the noise by using median filter
 
 [centroid, bbox] = step(hblob, binFrame); % Get the centroids and bounding boxes of the blobs
 rgbFrame(1:15,1:215,:) = 0; % put a black region on the output stream
 vidIn = step(hshapeinsWhiteBox, rgbFrame, bbox); % Instert the white box
 fprintf(d,m);
 for object = 1:1:length(bbox(:,1)) % Write the corresponding centroids
  vidIn = step(htextinsCent, vidIn, [centroid(object,1) centroid(object,2)], [centroid(object,1)-6 centroid(object,2)-9]); 
end
 vidIn = step(htextins, vidIn, uint8(length(bbox(:,1)))); % Count the number of blobs
 step(hVideoIn, vidIn); % Output video stream
 nFrame = nFrame+1;
I=(255*centroid(:,1))/640;  %Faz a proporçao da coordenada X do baricentro
%fprintf(d,centroid);    %Envia a coordenada XY do baricentro para o celular 
g=uint8(I);
fwrite(d,g); %Envia a coordenada X
J=(255*centroid(:,2))/480;  %Faz a proporçao da coordenada Y do baricentro
h=uint8(J);
fwrite(d,h);   %Envia a Proporçao da coordenada Y
end
release(hVideoIn); % Release all memory and buffer used
release(vidDevice);
clear bbox;
clear binFrame;
clear bwblueFrame;
clear bwgreenFrame;
clear bwredFrame;
clear centroid;
clear hVideoIn;
clear hblob;
clear hshapeinsWhiteBox;
clear htextins;
clear htextinsCent;
clear nFrame;
clear object;
clear rgbFrame;
clear thresh;
clear vidDevice;
clear vidIn;
clear vidInfo;
clc;
