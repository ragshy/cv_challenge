function binaryImage = imsegDeltaE(rgbImage,LAB_Mean,tolerance)
% Read in image into an array.
[rows columns numberOfColorBands] = size(rgbImage);
LMean=LAB_Mean(1);
aMean=LAB_Mean(2);
bMean=LAB_Mean(3);

% Convert image from RGB colorspace to lab color space.
cform = makecform('srgb2lab');
lab_Image = applycform(im2double(rgbImage),cform);

%% LAB color space calculations
% Extract out the color bands from the original image
% into 3 separate 2D arrays, one for each color component.
LChannel = lab_Image(:, :, 1); 
aChannel = lab_Image(:, :, 2); 
bChannel = lab_Image(:, :, 3); 
  
% Make uniform images of only that one single LAB color.
LStandard = LMean * ones(rows, columns);
aStandard = aMean * ones(rows, columns);
bStandard = bMean * ones(rows, columns);

% Create the delta images: delta L, delta A, and delta B.
deltaL = LChannel - LStandard;
deltaa = aChannel - aStandard;
deltab = bChannel - bStandard;

% Create the Delta E image.
% This is an image that represents the color difference.
% Delta E is the square root of the sum of the squares of the delta images.
deltaE = sqrt(deltaL .^ 2 + deltaa .^ 2 + deltab .^ 2);

% Display the Delta E image - the delta E over the entire image.
% subplot(2, 2, 3);
% imshow(deltaE, []);
% caption = sprintf('Delta E Image\n(Darker = Better Match)');
% title(caption, 'FontSize', 12);


%% Find pixels within that delta E.
binaryImage = deltaE <= tolerance;
% subplot(3, 4, 9);
% imshow(binaryImage, []);
% title('Matching Colors Mask', 'FontSize', 12);

% Mask the image with the matching colors and extract those pixels.
matchingColors = bsxfun(@times, rgbImage, cast(binaryImage, class(rgbImage)));
% subplot(2, 2, 4);
% imshow(matchingColors);
% caption = sprintf('Matching Colors (Delta E <= %.1f)', tolerance);
% title(caption, 'FontSize', 12);

% % Mask the image with the NON-matching colors and extract those pixels.
nonMatchingColors = bsxfun(@times, rgbImage, cast(~binaryImage, class(rgbImage)));
% subplot(3, 4, 11);
% imshow(nonMatchingColors);
% caption = sprintf('Non-Matching Colors (Delta E > %.1f)', tolerance);
% title(caption, 'FontSize', 12);

end