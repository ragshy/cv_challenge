function [F] = epa(correspondences)
% This function implements the 8-Point algorithm to determine 
% the fundamental matrix F

    % Create homogeneous coordinates x1 und x2
    x1 = correspondences(1:2,:);
    x2 = correspondences(3:4,:);
    num = numel(x1(1,:));
    normZ = ones(1,num);   
    x1 = [x1;normZ];
    x2 = [x2;normZ];
    
    % Calculate matrix A with kronecker product
    A = [];
    for i = 1:num
        kronecker = kron(x1(:,i),x2(:,i));      
        A = [A;kronecker'];    
    end
    
    % Singular value decomposition of A
    [~,~,V] = svd(A);

    % Estimation of the fundamental matrix F consisting of the right
    % singular vectors resulted from the svd of A    
    G = reshape(V(:,9),3,3);
    [U,S,V] = svd(G);   
    S(3,3) = 0;
    F = U * S * V';
    
end

