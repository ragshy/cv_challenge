files = dir('Datasets/Wiesn/*.jpg');
N = length(files);   % total number of files 
% loop for each file 
for i = 1:N
    thisfile = files(i).name;
    I1 = imread(append(files(i).folder,'/',thisfile));

    I1_gray = rgb2gray(I1);
    I1_gray(I1_gray<126)=0;
    I1_gray(I1_gray>126)=255;

    figure
    imshowpair(I1,I1_gray,'montage')
end
