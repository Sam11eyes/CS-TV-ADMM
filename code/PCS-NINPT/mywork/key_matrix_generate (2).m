

function key_matrix = key_matrix_generate (row, column,x02,mu2)

v = 0.15;
h = 0.45;
T0 = 1000;
d = 10;

     phi1sequence = FCCM( x02, mu2 , v, h, d*256*256 );
     key_matrix = matrix(phi1sequence, d, row, column);

end