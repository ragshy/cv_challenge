files = dir('Datasets/Kuwait/*.jpg');
N = length(files);   % total number of files 
% loop for each file 
imagesAll = cell(1,N);
fileNames = cell(1,N);

for i = 1:N
    thisfile = files(i).name;
    I1 = imread(append(files(i).folder,'/',thisfile));
    imagesAll{i}=I1;
    fileNames{i} = thisfile;
    
end

a = load('segment_characteristics.mat');
LAB_mean = a.LAB_mean

for i = 1:N
    rgbImage=imagesAll{i};
    % Display the original image.
    figure(i)
    subplot(2, 2, 1);
    imshow(rgbImage);
    title(fileNames{i});
    J = imhistmatch(rgbImage,[imagesAll{:}],'method','polynomial'); %<- only line for color correction
    subplot(2, 2, 2);
    imshow(J);
    what = string(LAB_mean.segment_type)=='snow';
    mask = imsegDeltaE(J,LAB_mean{5,1:3},20);
    
end
