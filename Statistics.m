clear;
clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.) 
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 16;
warning('off','all');
warning;

%JPG Dateien einlesen (k entspricht der Anzahl der JPG-Dateien):
myDir = uigetdir('Pictures'); 
filePattern = fullfile(myDir, '*.jpg');
jpegFiles = dir(filePattern);
for k = 1:length(jpegFiles)
  baseFileName = jpegFiles(k).name;
  fullFileName = fullfile(myDir, baseFileName);
  fprintf(1, 'Now reading %s\n', fullFileName);
  rgbImage = imread(fullFileName);
  Img{k}= rgbImage;


% Get the dimensions of the image.
% [rows, columns, numberOfColorChannels] = size(rgbImage);

% Display image (mit figure alle).
% figure('Name', baseFileName);
% h(1) = subplot(2, 2, 1);
% imshow(rgbImage, []);
% impixelinfo;
% axis on;
% caption = sprintf('Original Color Image\n%s', baseFileName);
% title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
% hp = impixelinfo(); % Set up status line to see values when you mouse over the image.
% % Set up figure properties:
% % Enlarge figure to full screen.
% set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0.05 1 0.95]);
% % Get rid of tool bar and pulldown menus that are along top of figure.
% % set(gcf, 'Toolbar', 'none', 'Menu', 'none');
% % Give a name to the title bar.
% set(gcf, 'Name', 'Demo by ImageAnalyst', 'NumberTitle', 'Off')
% drawnow;
%   
% % Get an indexed image.
    numberOfColorClasses = 3;
    [indexedImage_save, customColorMap] = rgb2ind(Img{k}, numberOfColorClasses);
    customColor{k,:} = customColorMap;
    indexedImage{k} = indexedImage_save;
    
    % %Date and Month Configuration
months = {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'June', ...
  'July', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};
monthNumber_save = str2double(baseFileName(6:7));  
monthNumber{k} = monthNumber_save;
date_save = string(baseFileName(1:4)) + '\' + months(monthNumber{k});
date{k} = date_save;


% Display the image.
% figure('Name', baseFileName)
subplot(3,4,k);
imshow(indexedImage{k}, []);
cbr = colormap(customColorMap);
colorbar
% colorbar('Ticks',[0,0.2,0.4,0.6,0.8,1,1.2,1.4,1.6,1.8,2]);
caption = sprintf('Color Segmentation Mask');
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
xlabel(date{k});
impixelinfo;
axis('on', 'image');
drawnow;
end

try
% Take the histogram
figure;   
for i = 1:k
[N(i,:),edges] = histcounts(indexedImage{i});
N(i,:) = N(i,:)./sum(N(i,:));
end
xticks(1:k)
b = bar(N,'stacked');
set(gca, 'XTickLabel',date);

%Percentage Values
ytext = cumsum(N,2) - 0.02; %y position of text
xtext = ones(size(ytext));
xtext = xtext + [0:k-1]'; %x position of text
textval = string(round(N*100,1)) + '%';
text(xtext(:),ytext(:),textval(:),'FontSize', 9, 'FontWeight', 'bold');

% classes and setting colours
b(1).FaceColor = customColorMap(1,:);
b(2).FaceColor = customColorMap(2,:);
b(3).FaceColor = customColorMap(3,:);
b(1).DisplayName = 'class 0';
b(2).DisplayName = 'class 1';
b(3).DisplayName = 'class 2';
caption = sprintf('Area Fractions Of Each Color Class');
xlabel('Datetime', 'FontSize', fontSize);
ylabel('Area Fraction', 'FontSize', fontSize);
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
legend show
grid on;
hObject = histogram(indexedImage{1}, 'normalization', 'probability','bar');
catch
    fprintf('Trailing input arguments must occur in name-value pairs %%s, skipped.\n');
end

% Tell user the answer.
message = sprintf('Done!\nNote: Percentage values of Bars under 3%% wo''nt be shown here!');
uiwait(helpdlg(message));

%Protokol
%Probleme: Wenn der Balken zu klein ist, verschieben sich die Prozentwerte
%Lösung: Balkendiagramme mit Wertigkeiten von 5% oder geringer haben keine
%Prozentanzeige
%Problem2: Bei Rainforest zb wäre es sinnvoller nur 2 Farben zu nehmen und
%bei Kuwait wäre es sinnvoller 5 Farben zu nehmen