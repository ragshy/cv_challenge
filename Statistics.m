clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 16;

% Get the name of the image the user wants to use.
baseFileName = 'Wiesn\2015_08.jpg';
folder = 'Pictures';
%'Brazilian Rainforest\1985_12.jpg'
%'Dubai\1990_12.jpg'
%'Columbia Glacier\2006_12.jpg'
%'Frauenkirche\2019_03.jpg'
%'Kuwait\2015_10.jpg'
%'Wiesn\2015_08.jpg'
fullFileName = fullfile(folder, baseFileName);
% Check if file exists.
if ~exist(fullFileName, 'file')
	% The file doesn't exist -- didn't find it there in that folder.
	% Check the entire search path (other folders) for the file by stripping off the folder.
	fullFileNameOnSearchPath = baseFileName; % No path this time.
	if ~exist(fullFileNameOnSearchPath, 'file')
		% Still didn't find it.  Alert user.
		errorMessage = sprintf('Error: %s does not exist in the search path folders.', fullFileName);
		uiwait(warndlg(errorMessage));
		return;
	end
end

rgbImage = imread(fullFileName);
% Get the dimensions of the image.
[rows, columns, numberOfColorChannels] = size(rgbImage)
% Display image.
h(1) = subplot(2, 2, 1);
imshow(rgbImage, []);
impixelinfo;
axis on;
caption = sprintf('Original Color Image\n%s', baseFileName);
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
hp = impixelinfo(); % Set up status line to see values when you mouse over the image.
% Set up figure properties:
% Enlarge figure to full screen.
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0.05 1 0.95]);
% Get rid of tool bar and pulldown menus that are along top of figure.
% set(gcf, 'Toolbar', 'none', 'Menu', 'none');
% Give a name to the title bar.
set(gcf, 'Name', 'Demo by ImageAnalyst', 'NumberTitle', 'Off')
drawnow;

% Get an indexed image.
numberOfColorClasses = 3;
[indexedImage, customColorMap] = rgb2ind(rgbImage, numberOfColorClasses);

% Display the image.
h(2) = subplot(2, 2, 2);
imshow(indexedImage, []);
cbr = colormap(customColorMap);
colorbar;
caption = sprintf('Color Segmentation Mask Image');
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
impixelinfo;
axis('on', 'image');
drawnow;

% Take the histogram
h(3) = subplot(2, 2, 3);
pos = get(h,'Position');
new = mean(cellfun(@(v)v(1),pos(1:2)));
set(h(3),'Position',[new,pos{end}(2:end)])
hObject = histogram(indexedImage, 'normalization', 'probability');
grid on;
%ANteil der Farben im Bild
caption = sprintf('Area Fractions Of Each Color Class');
xlabel('Class Number', 'FontSize', fontSize);
ylabel('Area Fraction', 'FontSize', fontSize);
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
xticks(0 : numberOfColorClasses - 1);
% Tell user the answer.
message = sprintf('Done!');
uiwait(helpdlg(message));