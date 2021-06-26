function [sd] = sampson(F, x1_pixel, x2_pixel)
   % This function calculates the Sampson distance based on the fundamental matrix F

    e3_hat = [0 -1 0 ; 1 0 0 ; 0 0 0];
    sd = sum(x2_pixel.*(F*x1_pixel)).^2 ./ (sum((e3_hat*F*x1_pixel).^2) + sum((e3_hat*F'*x2_pixel).^2));
    
end

