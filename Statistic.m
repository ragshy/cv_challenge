        % Function to segmented all images  
function  [N,image] = Statistic(mask,str,imagesAll,baseFileName)
%% Month/Year Calculations for graphics

mask_size = size(mask);
months = {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'June', ...
  'July', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};
counter = 1;

for Cellname = baseFileName
    FileName = char(Cellname);
    monthNumber = (FileName(6:7)); 
    yearNumber = (FileName(1:4));
    date_save = strcat(yearNumber,'/',monthNumber);
    date{counter} = date_save;
    counter = counter +1;
end
%% Probability Calculations
N_save = zeros(size(mask,1),2);
N = cell(1,size(mask,2));
% Load prototypes
if strcmpi(str,'all')
    for each_mask = 1:size(mask,2)
        for each_image = 1:size(mask,1)
               elu = mask{each_image,each_mask}; 
               absolute_num = histcounts(elu); 
               rel_num = absolute_num./sum(absolute_num);
%                if any(rel_num < 0.03)
%                    rel_num = [1 0]; 
%                end
               N_save(each_image,:) = rel_num;
               N{each_mask}=N_save;
        end 
    end
for i = 1: size(mask,2)
    for j = 1: size(mask,1)
        probability{j,1} = N{1,i}(j,2);
    end
    probability_save(:,i) = probability;
end
N = probability_save;
N = cell2mat(N);
% N(1,5) = 0.3;
% Erkennung der Restprozente
for i = 1: size(mask,1)
    if sum(N(i,:)) < 1
        N(i,6) = 1 - sum(N(i,:));
    else
        [val, idx] = max(N(i,:));
        N(i,:) = N(i,:)./sum(N(i,:));
        %rami_special = val - remains;
        %N(i,idx) = rami_special; 
    end
end 
else
    for each_image = 1:size(mask,1)               
            N_save(each_image,:) = histcounts(mask{each_image}); 
            N_save(each_image,:) = N_save(each_image,:)./sum(N_save(each_image,:));
            N = N_save;
    end
end
%% Area Detection
P = length(imagesAll);
Scale = TextRec(imagesAll,P);
Pix = PixLength(imagesAll,P);

multiple_x = cell(1,P);
multiple_y = cell(1,P);
x_m =cell(1,P);
y_m =cell(1,P);
A_image = cell(1,P);

for i = 1:P
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

for i = 1:P
    A_N(i,:) = N(i, :) .* A_image(:, i);
end
%% Histogram and detection of user input
%Figure for sections 
FigH = figure('Position', get(0, 'Screensize'));
xticks(1:length(baseFileName));
b = bar(N,'stacked'); 
set(gca, 'XTickLabel',date);
fontSize = 16;      
caption = sprintf('Area Fractions Of Each Sections');
xlabel('Datetime', 'FontSize', fontSize);
ylabel('Relative Area Fraction', 'FontSize', fontSize);
% ytickformat(gca, 'percentage');
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');


%Figure for Areas calculations 
FigH2 = figure('Position', get(0, 'Screensize'));
xticks(1:length(baseFileName));
area = bar(A_N,'stacked'); 
set(gca, 'XTickLabel',date);
fontSize = 16;      
caption = sprintf('Area Detection');
xlabel('Datetime', 'FontSize', fontSize);
ylabel('Absolute Area Fraction in m²', 'FontSize', fontSize);
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');


switch(str)
    case 'all'
        b(1).DisplayName = 'Forest';
        area(1).DisplayName = 'Forest';
        b(1).FaceColor = [0.4660, 0.6740, 0.1880];
        area(1).FaceColor = [0.4660, 0.6740, 0.1880];
        b(2).DisplayName = 'Snow';
        area(2).DisplayName = 'Snow';
        b(2).FaceColor = [0.874509803921569,0.898039215686275,0.929411764705882];
        area(2).FaceColor = [0.874509803921569,0.898039215686275,0.929411764705882];
        b(3).DisplayName = 'Water';
        area(3).DisplayName = 'Water';
        b(3).FaceColor = [0.5843 0.8157 0.9882];
        area(3).FaceColor = [0.5843 0.8157 0.9882];
        b(4).DisplayName = 'Land';
        area(4).DisplayName = 'Land';
        b(4).FaceColor = [0.8608 0.7608 0.6627];
        area(4).FaceColor = [0.8608 0.7608 0.6627];
        b(5).DisplayName = 'City';
        area(5).DisplayName = 'City';
        b(5).FaceColor = [0.6, 0, 0];
        area(5).FaceColor = [0.6, 0, 0];
        if size(N,2) == 6
            b(6).DisplayName = 'Rest';
            area(6).DisplayName = 'Rest';
            b(6).FaceColor = [0.172549019607843,0.266666666666667,0.333333333333333];
            area(6).FaceColor = [0.172549019607843,0.266666666666667,0.333333333333333];
        end
    case {'Forest','forest'}
        b(1).DisplayName = 'Rest';
        area(1).DisplayName = 'Rest';
        b(2).DisplayName = 'Forest';
        area(2).DisplayName = 'Forest';
        b(1).FaceColor = [0.172549019607843,0.266666666666667,0.333333333333333];
        area(1).FaceColor = [0.172549019607843,0.266666666666667,0.333333333333333];
        b(2).FaceColor = [0.4660, 0.6740, 0.1880];
        area(2).FaceColor = [0.4660, 0.6740, 0.1880];
    case {'Water','water'}
        b(1).DisplayName = 'Rest';
        area(1).DisplayName = 'Rest';
        b(2).DisplayName = 'Water';
        area(2).DisplayName = 'Water';
        b(1).FaceColor = [0.172549019607843,0.266666666666667,0.333333333333333];
        area(1).FaceColor = [0.172549019607843,0.266666666666667,0.333333333333333];
        b(2).FaceColor = [0.5843 0.8157 0.9882];
        area(2).FaceColor = [0.5843 0.8157 0.9882];
    case {'Snow','snow'} 
        b(1).DisplayName = 'Rest';
        area(1).DisplayName = 'Rest';
        b(2).DisplayName = 'Snow';
        area(2).DisplayName = 'Snow';
        b(1).FaceColor = [0.172549019607843,0.266666666666667,0.333333333333333];
        area(1).FaceColor = [0.172549019607843,0.266666666666667,0.333333333333333];
        b(2).FaceColor = [0.874509803921569,0.898039215686275,0.929411764705882];
        area(2).FaceColor = [0.874509803921569,0.898039215686275,0.929411764705882];
    case {'Manmade','manmade'}
        b(1).DisplayName = 'Rest';
        area(1).DisplayName = 'Rest';
        b(2).DisplayName = 'City';
        area(2).DisplayName = 'City';
        b(1).FaceColor = [0.172549019607843,0.266666666666667,0.333333333333333];
        area(1).FaceColor = [0.172549019607843,0.266666666666667,0.333333333333333];
        b(2).FaceColor = [0.6, 0, 0];
        area(2).FaceColor = [0.6, 0, 0];
    case {'Land','land'}
        b(1).DisplayName = 'Rest';
        area(1).DisplayName = 'Rest';
        b(2).DisplayName = 'Land';
        area(2).DisplayName = 'Land';
        b(1).FaceColor = [0.172549019607843,0.266666666666667,0.333333333333333];
        area(1).FaceColor = [0.172549019607843,0.266666666666667,0.333333333333333];
        b(2).FaceColor = [0.8608 0.7608 0.6627];
        area(2).FaceColor = [0.8608 0.7608 0.6627];
end
legend show
grid on;
saveas(FigH,'Barchart.png');
saveas(FigH2,'Area.png');
image = montage({'Barchart.png','Area.png'});
%image_statistic = imread('Barchart.png');
%image_area = imread('Area.png');

end
