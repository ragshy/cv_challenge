I1 = imread('yellowstone_left.png');
I2 = imread('yellowstone_right.png');

%I1 = imread('Kuwait/2015_02.jpg');
%I2 = imread('Kuwait/2015_10.jpg');
%% crop out google earth watermark
%crop = [0,0,1570,1000];

I1_cropped = I1;% imcrop(I1,crop);
I2_cropped = I2;% imcrop(I2,crop);

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


%% remove outliers
[fMatrix, epipolarInliers, status] = estimateFundamentalMatrix(...
  matchedPoints1, matchedPoints2, 'Method', 'RANSAC', ...
  'NumTrials', 10000, 'DistanceThreshold', 0.5, 'Confidence', 70.00);

if status ~= 0 || isEpipoleInImage(fMatrix, size(I1_cropped)) ...
  || isEpipoleInImage(fMatrix', size(I2_cropped))
  error(['Either not enough matching points were found or '...
         'the epipoles are inside the images. You may need to '...
         'inspect and improve the quality of detected features ',...
         'and/or improve the quality of your images.']);
end

inlierPoints1 = matchedPoints1(epipolarInliers, :);
inlierPoints2 = matchedPoints2(epipolarInliers, :);

figure;
showMatchedFeatures(I1_cropped, I2_cropped, inlierPoints1, inlierPoints2);
legend('Inlier points in I1', 'Inlier points in I2');

%% rectify
[t1, t2] = estimateUncalibratedRectification(fMatrix, ...
  matchedPoints1.Location, matchedPoints2.Location, size(I2_cropped));
tform1 = projective2d(t1);
tform2 = projective2d(t2);

[I1Rect, I2Rect] = rectifyStereoImages(I1, I2, tform1, tform2);
figure;
imshow(stereoAnaglyph(I1Rect, I2Rect));
title('Rectified Stereo Images (Red - Left Image, Cyan - Right Image)');

figure;
imshowpair(I1Rect, I2Rect,'montage');

