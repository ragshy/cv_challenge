function [robust_correspondences] = ransac(correspondences, varargin)
% This function implements the RANSAC algorithm to determine 
% robust corresponding image points
       
    %% Input parser
    % Known variables:
    % epsilon       estimated probability
    % p             desired probability
    % tolerance     tolerance to belong to the consensus-set
    % x1_pixel      homogeneous pixel coordinates
    % x2_pixel      homogeneous pixel coordinates
    
    % Default values
    defaultEpsilon = 0.5;
    defaultP = 0.5;
    defaultTolerance = 0.01;
    
    % Input parser
    p = inputParser;
    addParameter(p, 'epsilon', defaultEpsilon, @(x) isnumeric(x) && (x>0) && (x<1));
    addParameter(p, 'p', defaultP, @(x) isnumeric(x) && (x>0) && (x<1));
    addParameter(p, 'tolerance', defaultTolerance, @(x) isnumeric(x));
    parse(p, varargin{:});
    
    % Variable assignment
    epsilon = p.Results.epsilon;
    tolerance = p.Results.tolerance;
    p = p.Results.p;
    
    % Pixel coordinates calculation
    x1_pixel = [correspondences(1,:);correspondences(2,:);ones(1,numel(correspondences(1,:)))];
    x2_pixel = [correspondences(3,:);correspondences(4,:);ones(1,numel(correspondences(1,:)))];
        
    %% RANSAC algorithm preparation
    % Pre-initialized variables:
    % k                     number of necessary points
    % s                     iteration number
    % largest_set_size      size of the so far biggest consensus-set
    % largest_set_dist      Sampson distance of the so far biggest consensus-set
    % largest_set_F         fundamental matrix of the so far biggest consensus-set
    k = 8;
    s = (log(1-p) / log(1-(1-epsilon)^k));
    largest_set_size = 0;
    largest_set_dist = 1/0;
    
    %% RANSAC algorithm
    for i = 1:s
        
        % Estimation of fundamental matrix  from k randomly chosen image 
        % points with help of 8-Point algorithm
        msize = numel(correspondences(1,:));
        rand_corr = correspondences(:,randperm(msize, k));        
        F = epa(rand_corr);
        
        % Sampson distance from all corresponding image points
        sd = sampson(F, x1_pixel, x2_pixel);
          
        % Include pair of correspondence points to current consensus set
        % if Sampson distance smaller than tolerance
        consensus_set = correspondences(:,sd < tolerance);
        
        % For the current consensus set, calculate the number of included 
        % corresponding image points as well as the absolute Sampson 
        % distance by summing up all Sampson distances included in the 
        % current consensus set
        nr_pairs = size(consensus_set,2);
        tot_dist = sum(sd(sd < tolerance));
        
        % Compare the number of included corresponding image points with 
        % the up to now biggest one saved in largest_set_size. If the 
        % current set is bigger it is the new biggest one. If both are 
        % equally big compare the absolute Sampson distances of the current 
        % set and the up to now biggest one saved in largest_set_dist. The 
        % set with the smaller Sampson distance is the new biggest set. 
        % After each iteration adapt the values in 
        % largest_set_size and largest_set_dist according to the new biggest 
        % set. 
        if ((nr_pairs > largest_set_size) || ((nr_pairs == largest_set_size) && (tot_dist < largest_set_dist)))
            largest_set_size = nr_pairs;
            largest_set_dist = tot_dist;
            best_consensus_set = consensus_set;
        end
        
    end
    
    correspondences_robust = best_consensus_set;
end

