function interpolatedImage = interpolate_images(I1,I2)

% Convert uint8 image data
I1 = uint16(I1);
I2 = uint16(I2);

%Take the average image
interpolatedImage = uint8((I1+I2)./2);

end


