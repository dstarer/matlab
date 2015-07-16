%%  using HOG features and multiclass SVM classifier
%%  Object classification
%%  basic procedure for creating an object classifer
%%      1. Acquire a labeled data set with iamges of the desired object.
%%      2. Partition the data set into a training set and a test set.
%%      3. Train the classifier using features extracted from the training set.
%%      4. Test the classifier using features extracted from the test set.

%%  digit data set
%%  synthetic digit images are used for training
%%  handwritten digits are used to validate the accuracy of classifier
    
function digitClassificationHOG()
    %% Loading training and test data using imageSet
    load('digitDataSet.mat', 'trainingImages', 'trainingLabels', 'testImages');
    dataSetDir     = fullfile(matlabroot, 'toolbox', 'vision', 'visiondemos');
    trainingImages = fullfile(dataSetDir, trainingImages);
    testImages     = fullfile(dataSetDir, testImages);

    
    function J = preProcess(I)
        lvl = graythresh(I);
        J   = im2bw(I, lvl);
    end

    
    %% show training and test  samples
    figure;

    subplot(2, 3, 1);
    imshow(trainingImages{3,2});

    subplot(2, 3, 2);
    imshow(trainingImages{23,4});

    subplot(2, 3, 3);
    imshow(trainingImages{4,9});

    subplot(2, 3, 4);
    imshow(testImages{2,2});

    subplot(2, 3, 5);
    imshow(testImages{5,4});

    subplot(2, 3, 6);
    imshow(testImages{8,8});

    %% show pre-processing results

    exTestImage = imread(testImages{5, 4});
    exTrainImage = imread(trainingImages{23, 4});

    figure;
    subplot(2, 2, 1);
    imshow(exTrainImage);

    subplot(2, 2, 2);
    imshow(preProcess(exTrainImage));

    subplot(2, 2, 3);
    imshow(exTestImage);

    subplot(2, 2, 4);
    imshow(preProcess(exTestImage));

    %% using HOG feature

    img = imread(trainingImages{4, 3});
    % extract HOG feature and HOG visualization
    [hog_2x2, vis2x2] = extractHOGFeatures(img, 'CellSize', [2 2]);
    [hog_4x4, vis4x4] = extractHOGFeatures(img, 'CellSize', [4 4]);
    [hog_8x8, vis8x8] = extractHOGFeatures(img, 'CellSize', [8 8]);

    %Show the original image
    figure;
    subplot(2, 3, 1:3);
    imshow(img);

    subplot(2, 3, 4);
    plot(vis2x2);
    title({'CellSize = [2 2]'; ['Feature length = ' num2str(length(hog_2x2))]});

    subplot(2, 3, 5);
    plot(vis4x4);
    title({'CellSize = [4 4]'; ['Feature length = ' num2str(length(hog_4x4))]});

    subplot(2, 3, 6);
    plot(vis8x8);
    title({'CellSize = [8 8]'; ['Feature length = ' num2str(length(hog_8x8))]});

    cellSize = [4 4];
    hogFeatureSize = length(hog_4x4);

    %% Train the Classifier
    %% using SVM algorithm, we need to train 10 classes for the 
    %% digit classification problem

    % Train an SVM classifier for each digit
    digits = char('0'): char('9');

    for d = 1: numel(digits)
        % Pre-allocate trainingFeatures array
        numTrainingImages = size(trainingImages, 1);
        trainingFeatures = zeros(numTrainingImages, hogFeatureSize, 'single');

        % Extract HOG features from each training image.
        % trainingImages contains both positive and negative image samples.

        for i = 1: numTrainingImages
            img = imread(trainingImages{i, d});

            img = preProcess(img);

            trainingFeatures(i, :) = extractHOGFeatures(img, 'CellSize', cellSize);
        end

        % Train a classifier for a digit. Each row of traingingFeatures
        % contains the HOG features extracted for a single training image. The
        % trainingLabels indicate if the features are extracted from positive
        % (true) or negative(false) training images.

        svmclassifier(d) = svmtrain(trainingFeatures, trainingLabels(:, d));
    end

    %% Test the classifier


    for d = 1: numel(digits)

        % Pre-allocate testFeatures array
        numImages = size(testImages, 1);
        testFeatures = zeros(numImages, hogFeatureSize, 'single');

        % Extract feature from each test image
        for i = 1 : numImages
            img = imread(testImages{i, d});

            img = preProcess(img);

            testFeatures(i, :) = extractHOGFeatures(img, 'CellSize', cellSize);
        end

        for digit = 1: numel(svmclassifier)
            predictedLabels(:, digit, d) = svmclassify(svmclassifier(digit), testFeatures);
        end
    end

    displayTable(predictedLabels);
    
    function displayTable(labels)
        colHeadings = arrayfun(@(x)sprintf('svm(%d)',x),0:9,'UniformOutput',false);
        format = repmat('%-9s',1,11);
        header = sprintf(format,'digit  |',colHeadings{:});
        fprintf('\n%s\n%s\n',header,repmat('-',size(header)));
        for idx = 1:numel(digits)
            fprintf('%-9s', [digits(idx) '      |']);
            fprintf('%-9d', sum(labels(:,:,idx)));
            fprintf('\n')
        end
    end
end

