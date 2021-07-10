% This function calculates the scale length in pixels 
% and outputs it for each individual image

function [all_counts] = PixLength(imagesAll,N)

% create cell which will contain the Pixel lengths of the scale
all_counts = cell(1,N);

% Crop image and binarize
for k = 1:N
    I = imagesAll{k};
    Cropped_image = imcrop(I,[1200 1060 400 35]);
    R = rgb2gray(Cropped_image);
    Icorrected = imtophat(R,strel('disk',15));
    I = imbinarize(Icorrected);
    
    % This part works in such a way that the image is 
    % binarized and there is only 0 and 1 left. The reason for 
    % this is that the line over which the scale is always 
    % indicated is white on all pictures. The rightmost point 
    % is used as the starting point and it is moved to the left 
    % until a "0" is encountered, which allows you to determine 
    % the length of this line
    
    % This is the position of the rightmost
    % pixel of the white line
    x =369;
    y = 3;
    
    % Move until "0"
    count = 0;
    while(I(y, x)==1)
        count = count +1;
        x = x - 1;
    end
    
    % Store Pixel length 
    all_counts{1,k} = count;
end

end








