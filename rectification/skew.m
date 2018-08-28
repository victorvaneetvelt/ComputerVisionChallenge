%SKEW returns a skew-symmetric matrix.
%
%   M = skew(t)
%   returns to matrix M the 3-by-3 skew symmetric matrix of the given
%   3-vector t.
%
%Created 1999.
%
%Copyright Du Huynh
%The University of Western Australia
%School of Computer Science and Software Engineering

function M = skew(t)

M = [0 t(3) -t(2);
   -t(3) 0 t(1);
   t(2) -t(1) 0];

return;
