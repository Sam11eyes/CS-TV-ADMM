function reconstructed_image = EncodeFinal(yfinal,x01,x02,mu1,mu2)
    

v = 0.15;
h = 0.45;
d = 10;
a = 0;   
num_rows = 256;
num_cols = 256;
num_levels = 3; 
max_iterations = 5; 
    
    yfinal = double(yfinal);
    phi1sequence = FCCM( x01, mu1 , v, h, d*154*256 );
     Phi = matrix(phi1sequence, d, 154, 256);
    imean = 128 * ones(num_rows, num_rows);
    Y_template_matrix = Phi * imean;
    yfinal = yfinal + Y_template_matrix;

     key_matrix = key_matrix_generate (num_rows, num_cols,x01,mu1);
     NPT_model = NPTmodel (num_rows, num_cols ,x02,mu2); 
    
     

    reconstructed_image = PCS_PL_ED_Decoder (yfinal, Phi, key_matrix,  NPT_model , a, num_rows, num_cols, num_levels, max_iterations);

end

