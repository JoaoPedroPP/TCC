%% Initialization
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
while(nFrame < 30)
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
clear ;
clear ;
clear ;
clear ;
clear ;
clc;