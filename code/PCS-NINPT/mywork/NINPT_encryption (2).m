%  生成一个秘钥矩阵

% 时间：2020年5月18日

% 编程人：Bob


function encrypted_image  = NINPT_encryption (original_image, num_rows, num_cols, a, key_matrix, NPT_model)

encrypted_image = zeros(num_rows, num_cols);  

encrypted_image = round (a * key_matrix + (1-a) * original_image);      %  噪声模板加密
   
encrypted_image = negative_postive_transform (encrypted_image, NPT_model, num_rows, num_cols);      %  NPT加密  

    
end