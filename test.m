function [registered2] = test(I1,I2)

I1 = imread('Datasets/Wiesn/2015_06.jpg');
I2 = imread('Datasets/Wiesn/2015_07.jpg');

%% Harris measurement

    IGray1 = rgb2gray(I1);
    IGray2 = rgb2gray(I2);
    
    features1 = harris_detector(IGray1,'segment_length',9,'k',0.05,'min_dist',50,'N',20);
    features2 = harris_detector(IGray2,'segment_length',9,'k',0.05,'min_dist',50,'N',20);

%% Input parser
    
    window_length = 25;
    min_corr = 0.99;
    Im1 = double(I1);
    Im2 = double(I2);
    
%% Feature preparation
    
    [r1,c1] = size(Im1);
    [r2,c2] = size(Im2);
    Feat1 = [];
    Feat2 = [];
    window = floor(window_length/2);
    
    for i = 1:numel(features1(1,:))
        if ( ( (features1(1,i) - window) >= 1) && ( (features1(1,i) + window) <= c1) )
            if ( ( (features1(2,i) - window) >= 1) && ( (features1(2,i) + window) <= r1) )
                Feat1 = [Feat1,[features1(1,i) ; features1(2,i)]];               
            end
        end
    end
    
    for i = 1:numel(features2(1,:))
        if ( ( (features2(1,i) - window) >= 1) && ( (features2(1,i) + window) <= c2) )
            if ( ( (features2(2,i) - window) >= 1) && ( (features2(2,i) + window) <= r2) )
                Feat2 = [Feat2,[features2(1,i) ; features2(2,i)]];
            end
        end
    end
    
    Ftp1 = Feat1;
    Ftp2 = Feat2;
    
    no_pts1 = numel(Ftp1(1,:));
    no_pts2 = numel(Ftp2(1,:));

%% Normalization
    
    window = floor(window_length/2);
    Mat_feat_1 = [];
    Mat_feat_2 = [];

    for i = 1:no_pts1
        
        x_down = Ftp1(1,i) - window;
        x_up = Ftp1(1,i) + window;
        y_down = Ftp1(2,i) - window;
        y_up = Ftp1(2,i) + window;
        
        W = Im1( y_down:y_up , x_down:x_up );
        W = ( W - mean(W, 'all') ) ./ std(W, 0, 'all');
        
        Mat_feat_1 = [Mat_feat_1,reshape(W,1,[])'];     
    end
    
    for i = 1:no_pts2
        
        x_down = Ftp2(1,i) - window;
        x_up = Ftp2(1,i) + window;
        y_down = Ftp2(2,i) - window;
        y_up = Ftp2(2,i) + window;
        
        W = Im2( y_down:y_up , x_down:x_up );
        W = ( W - mean(W, 'all') ) ./ std(W, 0, 'all');
        
        Mat_feat_2 = [Mat_feat_2,reshape(W,1,[])'];     
    end

 %%
 
 i = false;
 while (i == false)
     
    ME = [];
    
    try   
       
    % NCC calculations
  
    x = numel(Mat_feat_1(1,:));
    y = numel(Mat_feat_2(1,:));
     
    NCC_matrix = zeros(y,x);
    temp = 1 / (window_length*window_length - 1);
 
    for i = 1:x
        for j = 1:y        
            
            ncc = temp * ( (Mat_feat_1(:,i))' * Mat_feat_2(:,j) );
                
            if (ncc > min_corr)
                NCC_matrix(j,i) = ncc;
            end
    
        end
    end
    
    indices = find(NCC_matrix);
    [~,~,val] = find(NCC_matrix);
    val_indices = [val, indices];
    
    [~,idx] = sort(val_indices(:,1),'descend');
    sorted = val_indices(idx,:);
   
    sorted_index = sorted(:,2);  
    
% Correspondeces

    n = numel(sorted_index);
    cor = [];
    
    for i = 1:n
        
        if (NCC_matrix(sorted_index(i)) ~= 0)
        
            [r,c] = ind2sub(size(NCC_matrix),sorted_index(i));
        
            cor = [cor,[Ftp1(:,c);Ftp2(:,r)]];
        
            NCC_matrix(:,c) = 0;
        end
        
    end
    
 % Transformation
     
        tform = estimateGeometricTransform2D(cor(3:4, :)',cor(1:2, :)','rigid');
        outputView = imref2d(size(I1));  
        registered2 = imwarp(I2,tform,'OutputView',outputView);
        figure;
        imshowpair(I1,registered2,'blend');
        i = true; 
    catch ME
    if ~isempty(ME)    
        min_corr = min_corr - 1 ;
    end
    end
end

