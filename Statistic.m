        % Function to segmented all images  
function N = Statistic(mask,str)
%% Month/Year Calculations for graphics

mask_size = size(mask);
months = {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'June', ...
  'July', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};
counter = 1;
baseFileName = load('basefileName.mat');
baseFileName = baseFileName.baseFileName_save;
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
               N_save(each_image,:) = rel_num;
               N{each_mask}=N_save;
        end
    end
else
    for each_image = 1:size(mask,1)               
            N_save(each_image,:) = histcounts(mask{each_image}); 
            N_save(each_image,:) = N_save(each_image,:)./sum(N_save(each_image,:));
            N = N_save;
    end
end
% counter = 1;
% for i = N{1,counter}
%     for j 
% %         if j < 0.02
% %             N(j) = 0;
% %         end
%     counter = counter +1;
%         if counter > size(N,1)
%             break
%         end
% end
%% Histogram and detection of user input

xticks(1:length(baseFileName));
b = bar(N,'stacked'); %1.Element Rest/2.Element gewählte Option
set(gca, 'XTickLabel',date);

switch(str)
    case 'all'
        disp(str)
        %Spaltennummer: 1:'Earth/Forest'/2:Water/3:Snow/4:Manmade/5:Land
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
        b(2).DisplayName = 'Manmade';
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

try
    hObject = histogram(N, 'normalization', 'probability','bar');
catch
    fprintf('Trailing input arguments must occur in name-value pairs %%s, skipped.\n');
end
end




