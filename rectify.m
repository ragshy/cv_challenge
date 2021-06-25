function I2_Rect = rectify(ImageName1,ImageName2)

%I1 = imread('yellowstone_left.png');
%I2 = imread('yellowstone_right.png');
I1 = imread('Datasets/Wiesn/2020_03.jpg');
I2 = imread('Datasets/Wiesn/2021_06.jpg');
%% crop out google earth watermark
crop = [0,0,1570,1000];

I1_cropped = imcrop(I1,crop);
I2_cropped = imcrop(I2,crop);

figure
imshowpair(I1_cropped,I2_cropped,'montage')

% Convert to grayscale.
I1gray = imadjust(rgb2gray(I1_cropped));
I2gray = imadjust(rgb2gray(I2_cropped));

figure;
imshow(stereoAnaglyph(I1_cropped,I2_cropped));
title('Composite Image (Red - Left Image, Cyan - Right Image)');

%% detect,extract features
feat1 = detectSURFFeatures(I1gray, 'MetricThreshold', 500);
feat2 = detectSURFFeatures(I2gray, 'MetricThreshold', 500);

[features1, validBlobs1] = extractFeatures(I1gray, feat1);
[features2, validBlobs2] = extractFeatures(I2gray, feat2);

%% match
indexPairs = matchFeatures(features1, features2, 'Metric', 'SAD', ...
  'MatchThreshold', 5);

matchedPoints1 = validBlobs1(indexPairs(:,1),:);
matchedPoints2 = validBlobs2(indexPairs(:,2),:);

figure;
showMatchedFeatures(I1_cropped, I2_cropped, matchedPoints1, matchedPoints2);
legend('Putatively matched points in I1', 'Putatively matched points in I2');

%% rigid transform/rectify
A = matchedPoints1.Location;
B = matchedPoints2.Location;

[R,t] = rigid_transform(A.',B.');
tform2 = rigid2d(R,t');

%% show rectified
I2_Rect = imwarp(I2_cropped,tform2);
figure;
imshowpair(I1_cropped,I2_Rect,'montage')

end
