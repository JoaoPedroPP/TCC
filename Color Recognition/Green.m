%% Initialization
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
while(nFrame < 30)
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
plot(centroidGreen(:,1),centroidGreen(:,2),'b*'); %Mostra a coordenada XY do baricentro
I=(255*centroidGreen)/640;  %Faz a proporçao da coordenada X do baricentro
%fprintf(d,centroid);    %Envia a coordenada XY do baricentro para o celular 
%fprintf(d,I);      %Envia a coordenada X
J=(255*centroidGreen(:,2))/480;  %Faz a proporçao da coordenada Y do baricentro
%fpintf(d,J);   %Envia a Proporçao da coordenada Y
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
clear centXGreen;
clear centYGreen;
clc;
%break;