% Homography - finds the relationship between (min) 4 corresponding points.
% The coordinates are passed as 1 row per point, where each row of s and p
% correspond, 2d coordinates will be made homogeneous.
% if option 'ransac' a homography will be fitted to the data and index to the
% inliers will be returned.
% ransac options:
% - 'threshold': set distance threshold, default=0.1
% - 'iterations': max number of iterations performed, default=2000
% - 'samplesize': nr of samples to be used for each iteration, default=4


function [H,inliers] = homography(s,p,varargin)
    
    s = validate( s );
    p = validate( p );
    
    % normalize data
    [ s, Ts ] = normalize(s);
    [ p, Tp ] = normalize(p);
    
        
    if ~isempty( varargin ) && strcmpi( varargin{1}, 'ransac' )
        [H,inliers] = ransac( @calcHomography, @homographyDistance, {s, p}, varargin{2:end} );
    else
        H = calcHomography( {s,p} );
        inliers = [];
    end
    
    % denormalize
    H = Ts\H*Tp;
    H = H/H(end,end);
    
end% homography

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% input validation
function o = validate( s )
    % validate input
    [r,c] = size(s);
    
    if r<4
        error( 'ERROR @ homography(): Not enough points.' );
    end
    
    if c==2% make homogeneous if neccessary
        o = [s,ones(r,1)];
    else
        o = s;
    end
    
    if size(o,2)~=3
        error( 'ERROR @ homography(): unexpected coordinate format.' );
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% homography calculation
function H = calcHomography( data )
        
        [r,c] = size(data{1});
        
        A = zeros( r*3, c*3 );
        
        j = 1;
        for i = 1:3:(r*3-2)
            s_skew = Skew( data{1}(j,:)' );
            A( i:i+2, : ) = [   data{2}(j,1)*s_skew,...
                                data{2}(j,2)*s_skew,...
                                data{2}(j,3)*s_skew     ];
            j = j+1;
        end% i 
        
        [~, ~ , v] = svd(A);
        
        h = v(:,9);
        
        H = [ h(1:3)    h(4:6)  h(7:9)  ];
        
        % check for singularity
        if rcond(H)<1e-7
            H = [];% bad homography, discard
        end
end% calcHomography

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% distance between corresponding points calculated from a homography
function dist = homographyDistance(Htest,data)
    
    tPoints = ( Htest*data{2}' )';
    tPoints = tPoints./repmat(tPoints(:,3),1,3);% normalize

    invPoints = (Htest\data{1}')';
    invPoints = invPoints./repmat(invPoints(:,3),1,3);% normalize

    % symmetric distance
    dist = sum((data{2}-invPoints).^2,2) + sum((data{1}-tPoints).^2,2);
end% homographyDistance
