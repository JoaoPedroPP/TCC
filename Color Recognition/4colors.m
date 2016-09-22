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
 'CustomBorderColor', [f7 f7 f7], ...
 'Fill', true, ...
 'FillColor', 'Custom', ...
 'CustomFillColor', [f7 f7 f7], ...
 'Opacity', 0.4);
htextinsRed = vision.TextInserter('Text', 'Red : %2d', ... % Set text for number of blobs
 'Location', [5 2], ...
 'Color', [f7 f7 f7], ... // red color
 'Font', 'Courier New', ...
 'FontSize', 14);
hVideoIn = vision.VideoPlayer('Name', 'Final Video', ... % Output video player
 'Position', [100 100 vidInfo.MaxWidth+20 vidInfo.MaxHeight+30]);
nFrame = 0; % Frame number initialization

%% Processing Loop
while(nFrame < 30)
 rgbFrame = step(vidDevice); % Acquire single frame
 rgbFrame = flipdim(rgbFrame,2); % obtain the mirror image for displaying

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
 end
 
 vidIn = step(htextinsRed, vidIn, uint8(length(bboxRed(:,1)))); % Count the number of red blobs
 step(hVideoIn, vidIn); % Output video stream
 nFrame = nFrame+1;
end

%% Clearing Memory
release(hVideoIn); % Release all memory and buffer used
release(vidDevice);
clear all;
clc;