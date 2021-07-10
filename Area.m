% Es soll
% Change here image
files = dir('Datasets/Brazilian Rainforest/*.jpg');
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

Scale = TextRec(imagesAll,N);
Pix = PixLength(imagesAll,N);
% 40000
% {[333]}    {[333]}    {[332]}    {[334]}    {[300]}    {[295]}    {[296]}    {[295]}

Percentage = 0.5;


N = length(files);   % total number of files 
imagesAll = cell(1,N);
fileNames = cell(1,N);
for i = 1:N
    thisfile = files(i).name;
    I1 = imread(append(files(i).folder,'/',thisfile));
    imagesAll{i}=I1;
    fileNames{i} = thisfile;
end

% Crop image and binarize
multiple_x = cell(1,N);
multiple_y = cell(1,N);
x_m =cell(1,N);
y_m =cell(1,N);
A_image = cell(1,N);
for i = 1:N
I = imagesAll{i};
[x y z] = size(I);
pixel_ges = x*y;

multiple_x{:,i} = x/Pix{:,i};
multiple_y{:,i} = y/Pix{:,i};
x_m{:,i} = Scale * multiple_x{:,i};
y_m{:,i} = Scale * multiple_y{:,i};
A_image{:,i} = x_m{:,i} * y_m{:,i}; 
end
A_image = cell2mat(A_image);



% files = dir('Datasets/Columbia Glacier/*.jpg');
% Scale2 = TextRec(files);
% Pix2 = PixLength(files);
% 
% files = dir('Datasets/Dubai/*.jpg');
% Scale3 = TextRec(files);
% Pix3 = PixLength(files);
% 
% files = dir('Datasets/Frauenkirche/*.jpg');
% Scale4 = TextRec(files);
% Pix4 = PixLength(files);
% 
% files = dir('Datasets/Kuwait/*.jpg');
% Scale5 = TextRec(files);
% Pix5 = PixLength(files);
% 
% files = dir('Datasets/Wiesn/*.jpg');
% Scale6 = TextRec(files);
% Pix6 = PixLength(files);





