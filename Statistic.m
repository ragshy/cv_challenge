        % Function to segmented all images  
function  [N,image] = Statistic(mask,str,baseFileName)
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
        remains = sum(N(i,:)) - 1;
        rami_special = val - remains;
        N(i,idx) = rami_special; 
    end
end 
else
    for each_image = 1:size(mask,1)               
            N_save(each_image,:) = histcounts(mask{each_image}); 
            N_save(each_image,:) = N_save(each_image,:)./sum(N_save(each_image,:));
            N = N_save;
    end
end
%% Histogram and detection of user input
FigH = figure('Position', get(0, 'Screensize'));
F    = getframe(FigH);
xticks(1:length(baseFileName));
b = bar(N,'stacked'); %Forest=1/snow=2/water=3/land=4/city=5
set(gca, 'XTickLabel',date);

switch(str)
    case 'all'
        b(1).DisplayName = 'Forest';
        b(1).FaceColor = [0.4660, 0.6740, 0.1880];
        b(2).DisplayName = 'Snow';
        b(2).FaceColor = [0.874509803921569,0.898039215686275,0.929411764705882];
        b(3).DisplayName = 'Water';
        b(3).FaceColor = [0.5843 0.8157 0.9882];
        b(4).DisplayName = 'Land';
        b(4).FaceColor = [0.8608 0.7608 0.6627];
        b(5).DisplayName = 'City';
        b(5).FaceColor = [0.6, 0, 0]; %[0.3 0.5 0.4];
        if size(N,2) == 6
            b(6).DisplayName = 'Rest';
            b(6).FaceColor = [0.172549019607843,0.266666666666667,0.333333333333333];
        end
    case {'Forest','forest'}
        b(1).DisplayName = 'Rest';
        b(2).DisplayName = 'Forest';
        b(1).FaceColor = [0.172549019607843,0.266666666666667,0.333333333333333];
        b(2).FaceColor = [0.4660, 0.6740, 0.1880];
    case {'Water','water'}
        b(1).DisplayName = 'Rest';
        b(2).DisplayName = 'Water';
        b(1).FaceColor = [0.172549019607843,0.266666666666667,0.333333333333333];
        b(2).FaceColor = [0.5843 0.8157 0.9882];
    case {'Snow','snow'} 
        b(1).DisplayName = 'Rest';
        b(2).DisplayName = 'Snow';
        b(1).FaceColor = [0.172549019607843,0.266666666666667,0.333333333333333];
        b(2).FaceColor = [0.874509803921569,0.898039215686275,0.929411764705882];
    case {'Manmade','manmade'}
        b(1).DisplayName = 'Rest';
        b(2).DisplayName = 'City';
        b(1).FaceColor = [0.172549019607843,0.266666666666667,0.333333333333333];
        b(2).FaceColor = [0.3 0.5 0.4];
    case {'Land','land'}
        b(1).DisplayName = 'Rest';
        b(2).DisplayName = 'Land';
        b(1).FaceColor = [0.172549019607843,0.266666666666667,0.333333333333333];
        b(2).FaceColor = [0.8608 0.7608 0.6627];
end
fontSize = 16;      
caption = sprintf('Area Fractions Of Each Color Class');
xlabel('Datetime', 'FontSize', fontSize);
ylabel('Area Fraction', 'FontSize', fontSize);
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
legend show
grid on;
saveas(gcf,'Barchart.png');
image = imread('Barchart.png');
end
