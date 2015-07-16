
%% detecing cars using Gaussian Mixture Models

%% step 1 initialize the foreground detector
%% The foreground detector requires a certain number of video frames
%% in order to initialize the Gaussian mixture model.
%% Here, we use the first 50 frames to initialize three Gaussian modes

foregroundDetector = vision.ForegroundDetector('NumGaussians', 3, 'NumTrainingFrames', 50);

videoReader = vision.VideoFileReader('visiontraffic.avi');

for i = 1:150
    frame = step(videoReader);          % read the next video frame
    foreground = step(foregroundDetector, frame);
end

%% show original picture
figure;
imshow(frame);
title('Video Frame');
%% show the foreground image
figure;
imshow(foreground);
title('Foreground');

%% step 2 Detect cars in an intial video frame
%% the foreground segmentation process is not prefect and often
%% includes undesiable noise.
%% We use morphological opening to remove the noise and to fill
%% gaps in the deteced objects.

se = strel('square', 3);
filteredForeground = imopen(foreground, se);
figure;
imshow(filteredForeground);
title('Clean Foreground');

%% Next we find bounding boxes of each connected component correspondingto a moving 
%% car by using vision.BlobAnalysis Object.The object filters the detected foreground 
%% by rejecting blobs which contain fewer than 150 pixels.

blobAnalysis = vision.BlobAnalysis('BoundingBoxOutputPort', true, 'AreaOutputPort', ...
    false, 'CentroidOutputPort', false, 'MinimumBlobArea', 150);

bbox = step(blobAnalysis, filteredForeground);

result = insertShape(frame, 'Rectangle', bbox, 'Color', 'red');

numCars = size(bbox, 1);

result = insertText(result, [10 10], numCars, 'BoxOpacity', 1, 'FontSize', 14);

figure;
imshow(result);
title('Detected Cars');


%% step 3 process the Reset of viode frames
%% process the remaining video frames

videoPlayer = vision.VideoPlayer('Name', 'Detected Cars');
videoPlayer.Position(3:4) = [650, 400]   % window size: [width, height]
se = strel('square', 3);

while ~isDone(videoReader)
    
    frame = step(videoReader); % read the next video frame
    
    % detect the foreground in the current video frame
    foreground = step(foregroudDetector, frame); 
    
    % Use morphological opening to remove noise in the foreground
    filteredForeground = imopen(foreground, se);
    
    % Detect the connected components with the specified mininum area,
    % and compute their bounding boxes
    bbox = step(blobAnalysis, filteredForeground);
    
    % Draw bounding boxes around the detected cars
    result = insertShape(frame, 'Rectangle', bbox, 'Color', 'green');
    
    % Display the number of cars found in the video frame
    numCars = size(bbox, 1);
    result = insertText(result, [10 10], numCars, 'BoxOpacity', 1, 'FontSize', 14);
    
    step(videoPlayer, result); % display the results
    
end

% close the video file
release(videoReader);

