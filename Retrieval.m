%%Select the Image Features for Retrieval
%%Create a Bag Of Features
%%Index the Images
%%Search for Similar Images

% Location of the compressed data set
url = 'http://www.robots.ox.ac.uk/~vgg/data/flowers/17/17flowers.tgz';

% Store the output in a temporary folder
outputFolder = fullfile(tempdir, '17Flowers'); % define output folder


if ~exist(outputFolder, 'dir') % download only once
    disp('Downloading 17-Category Flower Dataset (58 MB)...');
    untar(url, outputFolder);
end

flowerImageSet = imageSet(fullfile(outputFolder,'jpg'));

% Total number of images in the data set
flowerImageSet.Count

% Step 1  Select the Image Features for Retrieval

% Display a few of the flower images
helperDisplayImageMontage(flowerImageSet.ImageLocation(1:50:1000));


%% step2 Create a bag of features

%Pick a random subset of the flower images
trainingSet = partition(flowerImageSet, 0.4, 'randomized');

%Create a custom bag of features using the 'CustomExtractor' option
colorBag = bagOfFeatures(trainingSet, ...
  'CustomExtractor', @exampleBagOfFeaturesColorExtractor, ...
  'VocabularySize', 10000);

% Load pre-trained bagOfFeatures
load('savedColorBagOfFeatures.mat','colorBag');

% Step3 Index the Images
% Create a search index
flowerImageIndex = indexImages(flowerImageSet, colorBag, 'SaveFeatureLocations', false);

load('savedColorBagOfFeatures.mat', 'flowerImageIndex');

% step 4 Search for Similar Images
% Define a query image
queryImage = read(flowerImageSet, 502);

figure
imshow(queryImage)

% Search for the top 20 images with similar color content
[imageIDs, scores] = retrieveImages(queryImage, flowerImageIndex);

scores

% Display results using montage. Resize images to thumbnails first.
helperDisplayImageMontage(flowerImageSet.ImageLocation(imageIDs))

figure
plot(sort(flowerImageIndex.WordFrequency))

% Lower WordFrequencyRange
flowerImageIndex.WordFrequencyRange = [0.01 0.2];

% Re-run retrieval
[imageIDs, scores] = retrieveImages(queryImage, flowerImageIndex);

% Show results
helperDisplayImageMontage(flowerImageSet.ImageLocation(imageIDs))

