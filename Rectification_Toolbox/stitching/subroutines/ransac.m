% Performs RANSAC on a sample set s,p and finds best fitting <model> with inliers within
% a <distance> calculation.
% Options: 
% - 'threshold': set distance threshold, default=0.1
% - 'iterations': max number of iterations performed, default=2000
% - 'samplesize': nr of samples to be used for each iteration, default=4

function [M,inliersOut] = ransac( model, distance, data, varargin )

    M = [];
    inliersOut = [];
    
    thresh = 0.1;% threshold
    nit = 2000;% worst case nr of iterations
    ssz = 4;% sample size
    
    
    % parse arguments
    for i = 1:length( varargin )-1
        switch varargin{i}
            case 'threshold'
                thresh = varargin{i+1};
            case 'iterations' 
                nit = varargin{i+1};
            case 'samplesize'
                ssz = varargin{i+1};
        end% switch
    end% for i 
    
    
    len = length( data{1} );
    dataLen = length( data );
    sample = cell( dataLen,1 ); 
    nmaxInlier = ssz;
    
    pInlierSample = 0.99;% probability that at least 1 sample is free from outliers
    
    for i=1:nit
        
        if i>nit% adjusted iterations nr
            break;
        end
        
        %% get a random sample of ssize points
        sIndex = randperm( len, ssz );
        
        for j=1:dataLen
            sample{j} = data{j}(sIndex,:);
        end% for j
        
        %% compute a trial model
        Mtest = feval( model, sample );
        
        if isempty( Mtest )% not valid
            continue;
        end
        
        %% test trial model on data
        dist = feval( distance, Mtest,data );
        
        %% find inliers within threshold
        inlier = find( dist<thresh );
        nInlier = length( inlier );
        
        %% if this is the most inliers so far calc the model and keep inliers
        if nInlier > nmaxInlier
            
            for j=1:dataLen
                sample{j} = data{j}(inlier,:);
            end% for j
            
            M = feval(model, sample );
            inliersOut = inlier;
            nmaxInlier = nInlier;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %%TEST
%             fprintf('Inlier Nr before: %d ',nmaxInlier);
%             % test trial model on data
%             distTEST = feval( distance, M,data );
%         
%             % find inliers within threshold
%             inlierTEST = find( distTEST<thresh );
%             fprintf('After: %d\n',length( inlierTEST ) );
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % update number of samples
            pOutlier = 1 - nmaxInlier/len;
            nit = log(1-pInlierSample)/log(1-(1-pOutlier)^ssz );
        
        end
        
    end% for i
    
end% ransac

    