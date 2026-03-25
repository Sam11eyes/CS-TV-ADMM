
%   此函数用来对正负变换后的矩阵进行解密

function  dencrypted_image_NPT = negative_postive_inverse_transform (original_image, NPT_model, num_rows, num_cols)

dencrypted_image_NPT = original_image;                              %  将原始图像转换成-128到128灰度

% dencrypted_image_NPT = original_image +128;                              %  将原始图像转换成-128到128灰度

for i = 1: num_rows
    
    for j = 1: num_cols
        
        
        if NPT_model  (i, j) ==1
            
          dencrypted_image_NPT  (i, j) =   256- dencrypted_image_NPT  (i, j);
           
        else
            
         dencrypted_image_NPT  (i, j) =   dencrypted_image_NPT  (i, j);
          
        end
        
    end
    
end


