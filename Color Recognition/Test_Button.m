function varargout = testebotao1(varargin)
% TESTEBOTAO1 MATLAB code for testebotao1.fig
%      TESTEBOTAO1, by itself, creates a new TESTEBOTAO1 or raises the existing
%      singleton*.
%
%      H = TESTEBOTAO1 returns the handle to a new TESTEBOTAO1 or the handle to
%      the existing singleton*.
%
%      TESTEBOTAO1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TESTEBOTAO1.M with the given input arguments.
%
%      TESTEBOTAO1('Property','Value',...) creates a new TESTEBOTAO1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before testebotao1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to testebotao1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help testebotao1

% Last Modified by GUIDE v2.5 29-Oct-2013 09:56:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @testebotao1_OpeningFcn, ...
                   'gui_OutputFcn',  @testebotao1_OutputFcn, ...
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


% --- Executes just before testebotao1 is made visible.
function testebotao1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to testebotao1 (see VARARGIN)

% Choose default command line output for testebotao1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes testebotao1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = testebotao1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in b.
function b_Callback(hObject, eventdata, handles)
% hObject    handle to b (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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
 %fprintf(d,centroid);
 for object = 1:1:length(bbox(:,1)) % Write the corresponding centroids
  vidIn = step(htextinsCent, vidIn, [centroid(object,1) centroid(object,2)], [centroid(object,1)-6 centroid(object,2)-9]); 
end
 vidIn = step(htextins, vidIn, uint8(length(bbox(:,1)))); % Count the number of blobs
 step(hVideoIn, vidIn); % Output video stream
 nFrame = nFrame+1;
 
 I=(255*centroid(:,1))/640;  %Faz a propor�ao da coordenada X do baricentro
%fprintf(d,centroid);    %Envia a coordenada XY do baricentro para o celular 
g=uint8(I);
fwrite(d,g); %Envia a coordenada X
J=(255*centroid(:,2))/480;  %Faz a propor�ao da coordenada Y do baricentro
h=uint8(J);
fwrite(d,h);   %Envia a Propor�ao da coordenada Y
end
release(hVideoIn); % Release all memory and buffer used
release(vidDevice);
clear bbox;
clear binFrame;
clear bwblueFrame;
clear bwgreenFrame;
clear bwredFrame;
%clear centroid;
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
%clc;



% --- Executes on button press in a.
function a_Callback(hObject, eventdata, handles)
% hObject    handle to a (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
blueThresh = 0.15; % Threshold for blue detection

vidDevice = imaq.VideoDevice('winvideo', 1, 'RGB24_640x480', ... % Acquire input video stream
 'ROI', [1 1 640 480], ...
 'ReturnedColorSpace', 'rgb');
vidInfo = imaqhwinfo(vidDevice); % Acquire input video property
hblob = vision.BlobAnalysis('AreaOutputPort', false, ... % Set blob analysis handling
 'CentroidOutputPort', true, ... 
 'BoundingBoxOutputPort', true', ...
 'MinimumBlobArea', 600, ...
 'MaximumBlobArea', 3000, ...
 'MaximumCount', 10);
hshapeinsBlueBox = vision.ShapeInserter('BorderColor', 'Custom', ... % Set Blue box handling
 'CustomBorderColor', [0 0 1], ...
 'Fill', true, ...
 'FillColor', 'Custom', ...
 'CustomFillColor', [0 0 1], ...
 'Opacity', 0.4);
htextinsBlue = vision.TextInserter('Text', 'Blue : %2d', ... % Set text for number of blobs
 'Location', [5 34], ...
 'Color', [0 0 1], ... // blue color
 'Font', 'Courier New', ...
 'FontSize', 14);
htextinsCent = vision.TextInserter('Text', '+ X:%4d, Y:%4d', ... % set text for centroid
 'LocationSource', 'Input port', ...
 'Color', [1 1 0], ... // yellow color
 'Font', 'Courier New', ...
 'FontSize', 14);
hVideoIn = vision.VideoPlayer('Name', 'Final Video', ... % Output video player
 'Position', [100 100 vidInfo.MaxWidth+20 vidInfo.MaxHeight+30]);
nFrame = 0; % Frame number initialization

%% Processing Loop
while(nFrame < 150)
 rgbFrame = step(vidDevice); % Acquire single frame
 %rgbFrame = flipdim(rgbFrame,2); % obtain the mirror image for displaying
 
 diffFrameBlue = imsubtract(rgbFrame(:,:,3), rgb2gray(rgbFrame)); % Get blue component of the image
 diffFrameBlue = medfilt2(diffFrameBlue, [3 3]); % Filter out the noise by using median filter
 binFrameBlue = im2bw(diffFrameBlue, blueThresh); % Convert the image into binary image with the blue objects as white
 
 [centroidBlue, bboxBlue] = step(hblob, binFrameBlue); % Get the centroids and bounding boxes of the blue blobs
 centroidBlue = uint16(centroidBlue); % Convert the centroids into Integer for further steps 

 rgbFrame(1:50,1:90,:) = 0; % put a black region on the output stream
 vidIn = step(hshapeinsBlueBox, rgbFrame, bboxBlue); % Instert the blue box

 for object = 1:1:length(bboxBlue(:,1)) % Write the corresponding centroids for blue
  centXBlue = centroidBlue(object,1); centYBlue = centroidBlue(object,2);
  vidIn = step(htextinsCent, vidIn, [centXBlue centYBlue], [centXBlue-6 centYBlue-9]);
 end
 
 vidIn = step(htextinsBlue, vidIn, uint8(length(bboxBlue(:,1)))); % Count the number of blue blobs
 step(hVideoIn, vidIn); % Output video stream
 nFrame = nFrame+1;
end
fwrite(d,centXBlue);
%% Clearing Memory
release(hVideoIn); % Release all memory and buffer used
release(vidDevice);
clear bboxBlue;
clear binFrameBlue;
clear blueThresh;
clear centroidBlue;
clear diffFrameBlue;
clear hVideoIn;
clear hblob;
clear hshapeinsBlueBox;
clear htextinsBlue;
clear htextinsCent;
clear nFrame;
clear object;
clear rgbFrame;
clear vidDevice;
clear vidIn;
clear vidInfo;
clc;


% --- Executes on button press in v.
function v_Callback(hObject, eventdata, handles)
% hObject    handle to v (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
greenThresh = 0.05; % Threshold for green detection

vidDevice = imaq.VideoDevice('winvideo', 1, 'RGB24_640x480', ... % Acquire input video stream
 'ROI', [1 1 640 480], ...
 'ReturnedColorSpace', 'rgb');
vidInfo = imaqhwinfo(vidDevice); % Acquire input video property
hblob = vision.BlobAnalysis('AreaOutputPort', false, ... % Set blob analysis handling
 'CentroidOutputPort', true, ... 
 'BoundingBoxOutputPort', true', ...
 'MinimumBlobArea', 600, ...
 'MaximumBlobArea', 3000, ...
 'MaximumCount', 10);
hshapeinsGreenBox = vision.ShapeInserter('BorderColor', 'Custom', ... % Set Green box handling
 'CustomBorderColor', [0 1 0], ...
 'Fill', true, ...
 'FillColor', 'Custom', ...
 'CustomFillColor', [0 1 0], ...
 'Opacity', 0.4);
htextinsGreen = vision.TextInserter('Text', 'Green : %2d', ... % Set text for number of blobs
 'Location', [5 18], ...
 'Color', [0 1 0], ... // green color
 'Font', 'Courier New', ...
 'FontSize', 14);
htextinsCent = vision.TextInserter('Text', '+ X:%4d, Y:%4d', ... % set text for centroid
 'LocationSource', 'Input port', ...
 'Color', [1 1 0], ... // yellow color
 'Font', 'Courier New', ...
 'FontSize', 14);
hVideoIn = vision.VideoPlayer('Name', 'Final Video', ... % Output video player
 'Position', [100 100 vidInfo.MaxWidth+20 vidInfo.MaxHeight+30]);
nFrame = 0; % Frame number initialization

%% Processing Loop
while(nFrame < 150)
 rgbFrame = step(vidDevice); % Acquire single frame
 %rgbFrame = flipdim(rgbFrame,2); % obtain the mirror image for displaying
 
 diffFrameGreen = imsubtract(rgbFrame(:,:,2), rgb2gray(rgbFrame)); % Get green component of the image
 diffFrameGreen = medfilt2(diffFrameGreen, [3 3]); % Filter out the noise by using median filter
 binFrameGreen = im2bw(diffFrameGreen, greenThresh); % Convert the image into binary image with the green objects as white
 
 [centroidGreen, bboxGreen] = step(hblob, binFrameGreen); % Get the centroids and bounding boxes of the green blobs
 centroidGreen = uint16(centroidGreen); % Convert the centroids into Integer for further steps 

 rgbFrame(1:50,1:90,:) = 0; % put a black region on the output stream
 vidIn = step(hshapeinsGreenBox, rgbFrame, bboxGreen); % Instert the green box
 
 for object = 1:1:length(bboxGreen(:,1)) % Write the corresponding centroids for green
 % centXGreen = centroidGreen(object,1); centYGreen = centroidGreen(object,2);
  %vidIn = step(htextinsCent, vidIn, [centXGreen centYGreen], [centXGreen-6 centYGreen-9]);
  vidIn = step(htextinsCent, vidIn, [centroidGreen(object,1) centroidGreen(object,2)], [centroidGreen(object,1)-6 centroidGreen(object,2)-9]);
 end
 
 vidIn = step(htextinsGreen, vidIn, uint8(length(bboxGreen(:,1)))); % Count the number of green blobs
 step(hVideoIn, vidIn); % Output video stream
 nFrame = nFrame+1;
end
%plot(centroidGreen(:,1),centroidGreen(:,2),'b*'); %Mostra a coordenada XY do baricentro
%I=(255*centroidGreen)/640;  %Faz a propor�ao da coordenada X do baricentro
%fprintf(d,centroid);    %Envia a coordenada XY do baricentro para o celular 
%fprintf(d,I);      %Envia a coordenada X
%J=(255*centroidGreen(:,2))/480;  %Faz a propor�ao da coordenada Y do baricentro
%fpintf(d,J);   %Envia a Propor�ao da coordenada Y
%% Clearing Memory
release(hVideoIn); % Release all memory and buffer used
release(vidDevice);
clear bboxGreen;
clear binFrameGreen;
%clear centroidGreen;
clear diffFrameGreen;
clear greenThresh;
clear hVideoIn;
clear hblob;
clear hshapeinsGreenBox;
clear htextinsCent;
clear htextinsGreen;
clear nFrame;
clear object;
clear rgbFrame;
clear vidDevice;
clear vidIn;
clear vidInfo;
%clear centXGreen;
%clear centYGreen;
clc;


% --- Executes on button press in r.
function r_Callback(hObject, eventdata, handles)
% hObject    handle to r (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
redThresh = 0.15; % Threshold for red detection

vidDevice = imaq.VideoDevice('winvideo', 1, 'RGB24_640x480', ... % Acquire input video stream
 'ROI', [1 1 640 480], ...
 'ReturnedColorSpace', 'rgb');
vidInfo = imaqhwinfo(vidDevice); % Acquire input video property
hblob = vision.BlobAnalysis('AreaOutputPort', false, ... % Set blob analysis handling
 'CentroidOutputPort', true, ... 
 'BoundingBoxOutputPort', true', ...
 'MinimumBlobArea', 600, ...
 'MaximumBlobArea', 3000, ...
 'MaximumCount', 10);
hshapeinsRedBox = vision.ShapeInserter('BorderColor', 'Custom', ... % Set Red box handling
 'CustomBorderColor', [1 0 0], ...
 'Fill', true, ...
 'FillColor', 'Custom', ...
 'CustomFillColor', [1 0 0], ...
 'Opacity', 0.4);
htextinsRed = vision.TextInserter('Text', 'Red : %2d', ... % Set text for number of blobs
 'Location', [5 2], ...
 'Color', [1 0 0], ... // red color
 'Font', 'Courier New', ...
 'FontSize', 14);
htextinsCent = vision.TextInserter('Text', '+ X:%4d, Y:%4d', ... % set text for centroid
 'LocationSource', 'Input port', ...
 'Color', [1 1 0], ... // yellow color
 'Font', 'Courier New', ...
 'FontSize', 14);
hVideoIn = vision.VideoPlayer('Name', 'Final Video', ... % Output video player
 'Position', [100 100 vidInfo.MaxWidth+20 vidInfo.MaxHeight+30]);
nFrame = 0; % Frame number initialization

%% Processing Loop
while(nFrame < 150)
 rgbFrame = step(vidDevice); % Acquire single frame
 %rgbFrame = flipdim(rgbFrame,2); % obtain the mirror image for displaying

 diffFrameRed = imsubtract(rgbFrame(:,:,1), rgb2gray(rgbFrame)); % Get red component of the image
 diffFrameRed = medfilt2(diffFrameRed, [3 3]); % Filter out the noise by using median filter
 binFrameRed = im2bw(diffFrameRed, redThresh); % Convert the image into binary image with the red objects as white
 
[centroidRed, bboxRed] = step(hblob, binFrameRed); % Get the centroids and bounding boxes of the red blobs
 centroidRed = uint16(centroidRed); % Convert the centroids into Integer for further steps
  
 rgbFrame(1:50,1:90,:) = 0; % put a black region on the output stream
 vidIn = step(hshapeinsRedBox, rgbFrame, bboxRed); % Instert the red box
 
 for object = 1:1:length(bboxRed(:,1)) % Write the corresponding centroids for red
  centXRed = centroidRed(object,1); centYRed = centroidRed(object,2);
  vidIn = step(htextinsCent, vidIn, [centXRed centYRed], [centXRed-6 centYRed-9]); 
 %vidIn = step(htextinsCent, vidIn, [centroidRed(object,1) centroidRed(object,2)], [centroidRed(object,1)-6 centroidRed(object,2)-9]);
 end
 
 vidIn = step(htextinsRed, vidIn, uint8(length(bboxRed(:,1)))); % Count the number of red blobs
 step(hVideoIn, vidIn); % Output video stream
 nFrame = nFrame+1;
end
%plot(centroidRed(:,1),centroidRed(:,2),'b*'); %Mostra a coordenada XY do baricentro
%I=(255*centroidRed(:,1))/640;  %Faz a propor�ao da coordenada X do
%baricentro
%I=(255*centXRed)/640;
%fprintf(d,I);    %Envia a coordenada XY do baricentro para o celular 
%fwrite(d,I);      %Envia a coordenada X
%J=(255*centYRed)/480;  %Faz a propor�ao da coordenada Y do baricentro
%fwrite(d,J);   %Envia a Propor�ao da coordenada Y
%% Clearing Memory
release(hVideoIn); % Release all memory and buffer used
release(vidDevice);
clear ans;
clear bboxRed;
clear binFrameRed;
%clear centroidRed;
clear diffFrameRed;
clear hVideoIn;
clear hblob;
clear hshapeinsRedBox;
clear htextinsRed;
clear nFrame;
clear object;
clear redThresh;
clear rgbFrame;
clear vidDevice;
clear vidIn;
clear vidInfo;
%clear centXRed;
%clear centYRed;
clear htextinsCent;
clc;
