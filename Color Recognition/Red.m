%% Initialization
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
while(nFrame < 30)
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
plot(centroidRed(:,1),centroidRed(:,2),'b*'); %Mostra a coordenada XY do baricentro
I=(255*centroidRed(:,1))/640;  %Faz a proporçao da coordenada X do
%baricentro
%I=(255*centXRed)/640;
fprintf(d,I);    %Envia a coordenada XY do baricentro para o celular 
%fwrite(d,I);      %Envia a coordenada X
%J=(255*centYRed)/480;  %Faz a proporçao da coordenada Y do baricentro
%fwrite(d,J);   %Envia a Proporçao da coordenada Y
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
%break;