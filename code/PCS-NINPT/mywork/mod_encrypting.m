%  模加密运算

% 时间：2017年3月31日

% 编程人：Bob

function encrypt_image = mod_encrypting (original_image, key_matrix, size_images)

gravel_level =256;                                                   %   灰度值范围

encrypt_image = zeros(size_images, size_images);      %   加密后的矩阵

for i = 1: size_images
    
    for j = 1: size_images
        
       encrypt_image(i, j) = mod (original_image(i, j) + key_matrix(i, j), gravel_level) ;
       
    end
    
end

end