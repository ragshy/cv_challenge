function [image_array_pre] = preprocessing(image_array, nr_images)
% Function to preprocess a set of input images

%% Crop google earth water mark
% imcrop: crop image to target window size

win_size = [0, 0, 1570, 1000];

for i = 1:nr_images
    image_array_pre{i} = imcrop(image_array{i}, win_size);
end

%% Transform to grayscale image and increase image contrast
% imadjust: maps the intensity values from grayscale image to new image
% rgb2gray: convert rgb image to grayscale

for i = 1:nr_images
    image_array_pre_g{i} = imadjust(rgb2gray(image_array_pre{i}));
end

%% Detect features
% detectSURFFeatures:
% extractFeatures: 

for i = 1:nr_images
    % Feature detector
    detect_features = detectSURFFeatures(image_array_pre_g{i}, 'MetricThreshold', 500);
    
    % Feature descriptor
    [extract_features, extracted_validPoints] = extractFeatures(image_array_pre_g{i}, detect_features);
    
    % Save extracted features and valid blobs in cell arrays
    features{i} = extract_features;
    validPoints{i} = extracted_validPoints;
end

%% Match features and getting robust features
% matchFeatures: 
% ransac: 

for i = 1:nr_images-1
    % Get indices of matched features
    indexPairs = matchFeatures(features{i}, features{i+1}, 'Metric', 'SAD', 'MatchThreshold', 5);

    % Get matched points from indices
    matchedPoints1 = validPoints{i}(indexPairs(:, 1), :);
    matchedPoints2 = validPoints{i+1}(indexPairs(:, 2), :);
    
    % Prepare matched points for ransac algorithm
    correspondences = [matchedPoints1.Location'; matchedPoints2.Location'];
    
    % Calculate robust matches
    correspondences_rob = ransac(correspondences);
    
    % Save robust features
    %matchedPoints1_rob = correspondences_rob(1:2, :)';
    %matchedPoints2_rob = correspondences_rob(3:4, :)';
    matchedPoints_rob{i} = correspondences_rob;

    %figure;
    %showMatchedFeatures(image_array_pre{i}, image_array_pre{i+1}, matchedPoints1, matchedPoints2);
end

%% Image registration

for i = 1:nr_images-1
    
    tform{i} = estimateGeometricTransform2D(matchedPoints_rob{i}(3:4, :)',matchedPoints_rob{i}(1:2, :)','rigid');
    
    outputView = imref2d(size(image_array_pre{i}));
    
    image_array_pre{i+1} = imwarp(image_array_pre{i+1},tform{i},'OutputView',outputView);
 
    %figure;
    %imshowpair(image_array_pre{1},image_array_pre{i+1},'blend');
end

end

