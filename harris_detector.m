function [features] = harris_detector(image, varargin)

 %% Input parser
 
    default_SegLen = 15;
    default_k = 0.05;
    default_tau = 10^6;
    default_min_dist = 20;
    default_tile_size = [200 200];
    default_N = 5;
    
    p = inputParser;
    addRequired(p,'image');
    addParameter(p,'segment_length',default_SegLen,@(x) isnumeric(x)&&(x>1)&&(mod(x,2)==1));
    addParameter(p,'k',default_k,@(x) isnumeric(x)&&((x>0)&&(x<1)));
    addParameter(p,'tau',default_tau,@(x) isnumeric(x)&&(x>0));
    addParameter(p,'min_dist',default_min_dist,@(x) isnumeric(x)&&(x>0));
    addParameter(p,'tile_size',default_tile_size,@(x) isnumeric(x));
    addParameter(p,'N',default_N,@(x) isnumeric(x)&&(x>0));
    parse(p,image,varargin{:});
    
    segment_length = p.Results.segment_length;
    k = p.Results.k;
    tau = p.Results.tau;
    min_dist = p.Results.min_dist;
    [~, c] = size(p.Results.tile_size);
    if (c == 1)
        tile_size = [p.Results.tile_size, p.Results.tile_size];
    else 
        tile_size = p.Results.tile_size;
    end
    N = p.Results.N;
    
%% Preparation for feature extraction
        
        img = double(image);
        
        % Approximation of the image gradient 
        dx = [1,0,-1;2,0,-2;1,0,-1]; 
        dy = dx'; 
        Iy = conv2(img, dx, 'same');   
        Ix = conv2(img, dy, 'same');
        
        % Weighting
        w = fspecial('gaussian', [1,segment_length], segment_length);

        % Harris Matrix G
        G11 = conv2(w,w,Ix.^2, 'same');  
        G22 = conv2(w,w,Iy.^2, 'same');
        G12 = conv2(w,w,Ix.*Iy, 'same');
    
%% Feature extraction with the Harris measurement

    H = (G11 .* G22 - G12.^2) - k * (G11 + G22).^2;
    [r,c] = size(H);
    corners = zeros(r,c);
    
    for i=1:r
        for j=1:c
            if (H(i,j) >= tau)
                corners(i,j) = H(i,j);
            end
        end
    end
    
%% Feature preparation
    
    [r,c] = size(corners);
    container = zeros(r+2*min_dist,c+2*min_dist);
    size_container = size(container);
    size_corner = size(corners);
    bb = floor((size_container - size_corner)/2)+1;
    container(bb(1)+(0:size_corner(1)-1),bb(2)+(0:size_corner(2)-1)) = corners;
    corners = container;
       
    % Get indices
    indices = find(corners);
    % Get values
    [~,~,val] = find(corners);
    % Matrix with indices and corresponding values
    val_indices = [val, indices];
    
    % Sort values descending
    [~,idx] = sort(val_indices(:,1),'descend');
    % Sort indices corresponding to values
    sorted = val_indices(idx,:);
    
    %Give sorted indices to output
    sorted_index = sorted(:,2);

%% Accumulator array

    [img_r, img_c] = size(image);
    acc_array = zeros(ceil(img_r/tile_size(1,1)),ceil(img_c/tile_size(1,2)));
    
%% Harris detector

    Cake = cake(min_dist);
    features = [];
    
    for i = 1:length(sorted_index)
        
        cur_ind = sorted_index(i);
        [y,x] = ind2sub(size(corners),cur_ind);
        cur_val = corners(y,x);
        
        if (cur_val ~= 0)
            x_val_acc_arr = ceil((x - min_dist)/tile_size(1));
            y_val_acc_arr = ceil((y - min_dist)/tile_size(1));
            
            if (acc_array(y_val_acc_arr,x_val_acc_arr) < N)
                corners(y-min_dist:y+min_dist,x-min_dist:x+min_dist) = corners(y-min_dist:y+min_dist,x-min_dist:x+min_dist) .* Cake;
                acc_array(y_val_acc_arr,x_val_acc_arr) = acc_array(y_val_acc_arr,x_val_acc_arr) + 1;
                features = [features, [x - min_dist;y - min_dist]];
            else
                corners(y,x) = 0;
            end           
        end         
    end
    
end

