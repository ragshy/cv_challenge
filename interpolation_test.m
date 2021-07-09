files = dir('Datasets/Columbia Glacier/*.jpg');
N = length(files);   % total number of files 
% loop for each file 
imagesAll = cell(1,N);
image_array_rec = cell(1,N);
fileNames = cell(1,N);

for i = 1:N
    thisfile = files(i).name;
    I1 = imread(append(files(i).folder,'/',thisfile));
    imagesAll{i}=I1;
    fileNames{i} = thisfile;
    
end

% Image registration first two images
[im1,im2] = preprocessing5(imagesAll{1}, imagesAll{2});
image_array_rec{1} = im1;
image_array_rec{2} = im2;

% Image registration rest of images
for i = 3:N
    [~,im2] = preprocessing5(imagesAll{1}, imagesAll{i});
    image_array_rec{i} = im2;
end 

%Interpolate, slower
for i = 1:(N-1)
    interpolated_image = interpolate_images(image_array_rec{i}, image_array_rec{i+1});
    figure
    imshow(image_array_rec{i})
    figure
    imshow(interpolated_image)
end 


