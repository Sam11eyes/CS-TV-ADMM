
%   此函数用来对正负变换后的矩阵进行加密

function encrypted_image_NPT = negative_postive_transform (original_image, NPT_model, num_rows, num_cols)


for i = 1: num_rows
    
    for j = 1: num_cols
        
        
        if NPT_model  (i, j) ==1
            
          encrypted_image_NPT  (i, j) =   256-original_image (i, j);
           
        else
            
          encrypted_image_NPT  (i, j) =   original_image (i, j);
          
        end
        
    end
    
end

% encrypted_image_NPT = encrypted_image_NPT -128;                              %  将原始图像转换成-128到128灰度

