function [I1_cropped,registered2] = preprocessing4(ImageName1,ImageName2, Image1_hist, Image2_hist)

% Read images for testing purposes
%ImageName1 = imread('Datasets/Wiesn/2015_06.jpg');
%ImageName2 = imread('Datasets/Wiesn/2019_09.jpg');

% Crop watermark
crop = [0,0,1570,1000];
I1_cropped = imcrop(ImageName1,crop);
I2_cropped = imcrop(ImageName2,crop);
I1_hist_cropped = imcrop(Image1_hist,crop);
I2_hist_cropped = imcrop(Image2_hist,crop);

% Convert to grayscale.
I1gray = imadjust(rgb2gray(I1_hist_cropped));
I2gray = imadjust(rgb2gray(I2_hist_cropped));

%I1cont = imfilter(histeq(I1gray,10),fspecial('sobel'));
%I2cont = imfilter(histeq(I2gray,10),fspecial('sobel'));

I1cont = I1gray;
I2cont = I2gray;

% Find features using SURF
% Feature detector
feat1 = detectSURFFeatures(I1cont, 'MetricThreshold', 300);
feat2 = detectSURFFeatures(I2cont, 'MetricThreshold', 300);

% Feature descriptor
[features1, validBlobs1] = extractFeatures(I1cont, feat1);
[features2, validBlobs2] = extractFeatures(I2cont, feat2);

%% Image matching and registration

indexPairs = matchFeatures(features1, features2, 'Metric', 'SAD', 'MatchThreshold', 100, 'MaxRatio', 0.6);

matchedPoints1_SURF = validBlobs1(indexPairs(:,1),:);
matchedPoints2_SURF = validBlobs2(indexPairs(:,2),:);

%figure;
%showMatchedFeatures(I1_cropped, I2_cropped, matchedPoints1_SURF, matchedPoints2_SURF);

% Try to get image transformation for image registration. If algorithm
% fails due to to suffiecient number of inliers, try kNN search
ME = [];
try
    % Get image transformation for image registration
    tform = estimateGeometricTransform2D(matchedPoints2_SURF,matchedPoints1_SURF,'rigid');
    
    % Calculate image registration
    Rfixed = imref2d(size(I1_cropped));
    registered2 = imwarp(I2_cropped,tform,'OutputView',Rfixed);   
    
    % Show output for testing purposes
    figure;
    imshowpair(I1_cropped,registered2,'diff');
    title('1');
    
catch ME
if ~isempty(ME)
    
    I1cont = I1gray;
    I2cont = I2gray;

    % Find features using SURF
    % Feature detector
    feat1 = detectSURFFeatures(I1cont, 'MetricThreshold', 500);
    feat2 = detectSURFFeatures(I2cont, 'MetricThreshold', 500);

    % Feature descriptor
    [features2, validBlobs2] = extractFeatures(I2gray, feat2);
        
    % Select N strongest features for kNN search
    strongestPoints = selectStrongest(feat1,200);
    [features1_strongest, validBlobs1_strongest] = extractFeatures(I1gray, strongestPoints);

    % Perform kNN search
    Idx = knnsearch(features2,features1_strongest);

    % Get matched points
    matchedPoints1_kNN = validBlobs1_strongest;
    matchedPoints2_kNN = validBlobs2(Idx,:);

    % Show output for testing purposes
    %figure;
    %showMatchedFeatures(I1_cropped, I2_cropped, matchedPoints1_kNN, matchedPoints2_kNN);

    % Get image transformation for image registration
    tform = estimateGeometricTransform2D(matchedPoints2_kNN,matchedPoints1_kNN,'similarity');
    
    % Calculate image registration
    Rfixed = imref2d(size(I1_cropped));
    registered2 = imwarp(I2_cropped,tform,'OutputView',Rfixed);
    
    % Show output for testing purposes
    figure;
    imshowpair(I1_cropped,registered2,'diff');
    title('2');
    
end
    
end

end


