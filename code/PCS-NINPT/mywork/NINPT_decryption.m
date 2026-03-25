%  生成一个秘钥矩阵

% 时间：2020年5月18日

% 编程人：Bob


function reconstructed_image  = NINPT_decryption (encrypted_image, num_rows, num_cols, a, key_matrix, NPT_model)

original_image = zeros(num_rows, num_cols);  

reconstructed_image = negative_postive_transform (encrypted_image, NPT_model, num_rows, num_cols);      %  NPT解密  
 
reconstructed_image = (reconstructed_image - a* key_matrix)/(1-a);
    
end