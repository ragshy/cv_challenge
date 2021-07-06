files = dir('Datasets/Wiesn/*.jpg');
N = length(files);   % total number of files 
% loop for each file 
images = cell(1,N);
for i = 1:N
    thisfile = files(i).name;
    I1 = imread(append(files(i).folder,'/',thisfile));
    images{i}=I1;
    
end

snow  = [244.6 246.2 247.3];%1
trees = [25 125 50];%2
water = [69 117 180];%3

centroids = [snow;trees;water]

I = images{1};
ref = I;


threshRGB = multithresh(I,1);
value = [0 threshRGB(2:end) 255]; 
for i = 1:N
    I = images{i};
    
    J = imhistmatch(I,ref,256,'method','polynomial');
    
    I_seg = imquantize(J, threshRGB,value);
    
    figure
    title('Original  |  hist match  |  Segmentiert')
    montage({I,J,I_seg},'Size',[1 3])
    %title('quantized Image');
end

% [L,Centers] = imsegkmeans(I,4,'NormalizeInput',true);
% B = labeloverlay(I,L);
% figure;
% imshowpair(B,I,'montage');
% title('kmeans Image');

