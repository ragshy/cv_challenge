function [ImageName1,registered2,tform] = imageReg(ImageName1,ImageName2)

% Read images for testing purposes
%ImageName1 = imread('Datasets/Wiesn/2015_06.jpg');
%ImageName2 = imread('Datasets/Wiesn/2019_09.jpg');

% Crop watermark
% crop = [0,0,1570,1000];
% I1_cropped = imcrop(ImageName1,crop);
% I2_cropped = imcrop(ImageName2,crop);

% Convert to grayscale.
I1gray = imadjust(rgb2gray(ImageName1));
I2gray = imadjust(rgb2gray(ImageName2));

%I1cont = imfilter(histeq(I1gray,10),fspecial('sobel'));
%I2cont = imfilter(histeq(I2gray,10),fspecial('sobel'));
%I1cont = histeq(I1gray);
%I2cont = histeq(I2gray);
I1cont = I1gray;
I2cont = I2gray;

%figure;
%montage({I1gray,I1cont,I2gray,I2cont},'Size',[1 4])

% Find features using SURF
% Feature detector
feat1 = detectSURFFeatures(I1cont, 'MetricThreshold', 300);
feat2 = detectSURFFeatures(I2cont, 'MetricThreshold', 300);

% Feature descriptor
[features1, validBlobs1] = extractFeatures(I1gray, feat1);
[features2, validBlobs2] = extractFeatures(I2gray, feat2);

%% Image matching and registration

indexPairs = matchFeatures(features1, features2, 'Metric', 'SAD', ...
  'MatchThreshold', 100);

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
    Rfixed = imref2d(size(ImageName1));
    registered2 = imwarp(ImageName2,tform,'OutputView',Rfixed);   
    
    % Show output for testing purposes
    %figure;
    %imshowpair(I1_cropped,registered2,'diff');
    %title('1');
    
catch ME
if ~isempty(ME)

    %figure;
    %montage({I1gray,I1cont,I2gray,I2cont},'Size',[1 4])

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
    Rfixed = imref2d(size(ImageName1));
    registered2 = imwarp(ImageName2,tform,'OutputView',Rfixed);
    
    % Show output for testing purposes
    %figure;
    %imshowpair(I1_cropped,registered2,'diff');
    %title('2');
end   
    
end

end
