function [I1_cropped,registered2] = rectify2(ImageName1,ImageName2)

I1 = imread('Datasets/Wiesn/2020_03.jpg');
I2  = imread('Datasets/Wiesn/2021_06.jpg');

crop = [0,0,1570,1000];

I1_cropped = imcrop(I1,crop);
I2_cropped = imcrop(I2,crop);

%I1_cropped = imcrop(ImageName1,crop);
%I2_cropped = imcrop(ImageName2,crop);

figure
imshowpair(I1_cropped,I2_cropped,'montage');

%% Find matching features

% Convert to grayscale.
I1gray = imadjust(rgb2gray(I1_cropped));
I2gray = imadjust(rgb2gray(I2_cropped));

% Feature detector
feat1 = detectSURFFeatures(I1gray, 'MetricThreshold', 500);
feat2 = detectSURFFeatures(I2gray, 'MetricThreshold', 500);

% Feature descriptor
[features1, validBlobs1] = extractFeatures(I1gray, feat1);
[features2, validBlobs2] = extractFeatures(I2gray, feat2);

% Matching
indexPairs = matchFeatures(features1, features2, 'Metric', 'SAD', ...
  'MatchThreshold',4);

matchedPoints1 = validBlobs1(indexPairs(:,1),:);
matchedPoints2 = validBlobs2(indexPairs(:,2),:);

% figure;
% showMatchedFeatures(I1_cropped, I2_cropped, matchedPoints1, matchedPoints2);


%% Image Transformation

tform = fitgeotrans(matchedPoints2.Location,matchedPoints1.Location,'projective');

Rfixed = imref2d(size(I1_cropped));

registered2 = imwarp(I2_cropped,tform,'OutputView',Rfixed);

figure
imshowpair(I1_cropped,registered2,'blend');
%figure
%imshow(I1_cropped);
%figure
%imshow(registered2);

end