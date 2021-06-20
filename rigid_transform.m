% From https://github.com/nghiaho12/rigid_transform_3D/blob/master/rigid_transform_3D.m
% This function finds the optimal Rigid/Euclidean transform in 2D space
% It expects as input a 2xN matrix of 2D points.
% It returns R, t

% expects row data
function [R,t] = rigid_transform(A, B)
    if nargin ~= 2
	    error("Missing parameters");
    end

    [num_rows, num_cols] = size(A);
    if num_rows ~= 2
        error("matrix A is not 2xN, it is %dx%d", num_rows, num_cols)
    end

    [num_rows, num_cols] = size(B);
    if num_rows ~= 2
        error("matrix B is not 2xN, it is %dx%d", num_rows, num_cols)
    end

    % find mean column wise
    centroid_A = mean(A, 2);
    centroid_B = mean(B, 2);

    % subtract mean
    Am = A - repmat(centroid_A, 1, num_cols);
    Bm = B - repmat(centroid_B, 1, num_cols);

    % calculate covariance matrix (is this the correct terminology?)
    H = Am * Bm';

    %if rank(H) < 3
    %    error(sprintf("rank of H = %d, expecting 3", rank(H)))
    %end

    % find rotation
    [U,S,V] = svd(H);
    R = V*U';

    if det(R) < 0
        disp("det(R) < R, reflection detected!, correcting for it ...\n");
        V(:,2) = -1*V(:,2);
        R = V*U';
    end

    t = -R*centroid_A + centroid_B;
end