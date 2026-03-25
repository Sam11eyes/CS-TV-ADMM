%  模加密运算

% 时间：2017年3月31日

% 编程人：Bob

function decrypt_image = mod_decrypting (encrypt_image, key_matrix, size_images)

gravel_level =256;                                                            %   灰度值范围

decrypt_image = zeros (size_images, size_images);       %    解密密后的矩阵

for i = 1: size_images
    
    for j = 1: size_images
        
       decrypt_image(i, j) = mod (encrypt_image(i, j) - key_matrix(i, j) + gravel_level, gravel_level) ;
       
    end
    
end