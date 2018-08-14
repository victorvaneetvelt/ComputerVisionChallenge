function [distance] = depthCalculation(f,E,disparity)

[U,S,V]=svd(E);

[T1, R1, T2, R2, U, V]=TR_aus_E(E);

[T,R,lambda]=rekonstruktion(T1,T2,R1,R2,Korrespondenzen,K);

    %compute distance
    for i = 1:1:size(disparity,1)
           for j = 1:1:size(disparity,2)
                 distance(i,j) = (f*T)./disparity(i,j);
            end
    end
end

