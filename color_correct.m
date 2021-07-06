files = dir('Datasets/Columbia Glacier/*.jpg');
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

ref=[imagesAll{:}];
figure(1);
imshow(ref);

figure(2)
for i = 1:3
    I = imagesAll{i};
    
    J = imhistmatch(I,[imagesAll{:}],'method','polynomial'); %<- only line for color correction
    subplot(3,1,i);
    imshowpair(I,J,'montage')
end
