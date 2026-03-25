function [ hash ,yfinal3] = GetFinal(x01,x02,mu1,mu2,file)




%混沌系统的参数设置
v = 0.15;
h = 0.45;
d = 10;


a = 0;                                                    %     噪声控制因子

quantizer_bitdepth = 6;                       %     比特深度

                       %     最大迭代次数
 
size_images = 256;                               %     图像维度，考虑方阵



% 读取图像

                                 %     存储图像变量

original_image = double (file);        %      读图像

[num_rows, num_cols] = size(original_image);                    %      计算图像的行和列


%%  加密阶段

%  注入噪声的NPT加密

%  生成一个注入的噪声信号

key_matrix = key_matrix_generate (num_rows, num_cols,x01,mu1);

%  NPT加密矩阵 

% coffused_image = 0.9 * carrier_image + 0.1 * original_image;
% 
NPT_model = NPTmodel (num_rows, num_cols ,x02,mu2); 
% 
encrypted_image  = NINPT_encryption (original_image, num_rows, num_cols, a, key_matrix, NPT_model);

figure(9);
imshow(uint8(encrypted_image),'Border','tight');



imean = 128 * ones(size_images, size_images);
encrypted_image = encrypted_image - imean;
      
     
     phi1sequence = FCCM( x01, mu1 , v, h, d*154*256 );
     Phi = matrix(phi1sequence, d, 154, 256);

     %  CS测量
    

              
     y =  Phi  *  encrypted_image;                        %    测量值计算

     

%  测量值量化

[y_sq, ~] = SQ_Coding (y, quantizer_bitdepth, num_rows, num_cols);                    %   普通熵编码

yfinal = y_sq;
yfinal2 = round(yfinal);
yfinal3 = int8(yfinal2);

    a = 1 ;b = 1 ;c = 1 ;d = 2 ;%%四维维cat映射的参数
tic;
A = matrixHash_chaotic_Very2(yfinal3,a,b,c,d,x01,mu1);
toc;

   hash = logicalToHex(A);


end



function hexStr = logicalToHex(logicalVec)
    % 验证输入是否为128位逻辑向量
    if ~islogical(logicalVec) || numel(logicalVec) ~= 128
        error('输入必须是128位逻辑向量');
    end
    
    % 将逻辑向量转为二进制字符串（无空格）
    binStr = sprintf('%d', logicalVec);
    
    % 补齐长度至4的倍数（128已是4的倍数，可跳过）
    if mod(length(binStr), 4) ~= 0
        binStr = [repmat('0', 1, 4 - mod(length(binStr), 4)), binStr];
    end
    
    % 每4位一组转换为十六进制字符
    hexStr = '';
    for i = 1:4:length(binStr)
        quad = binStr(i:i+3);                % 取4位二进制
        decVal = bin2dec(quad);               % 转为十进制（0-15）
        hexChar = dec2hex(decVal);            % 转为单字符十六进制
        hexStr = [hexStr, hexChar];           % 拼接结果
    end
end







