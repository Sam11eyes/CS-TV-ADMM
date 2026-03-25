%  嵌入NINPT的并行压缩感知（KPA分析实验）
 
%  编程人：张  波

%  修订：  2020年12月31日

%  单位：  固定通信系信息通信系统教研室

clc;

clear;

%  将需要的数据加入路径

addpath('C:\Users\zb\Desktop\PCS-NINPT\dataset11');                       %     原图

addpath('C:\Users\zb\Desktop\PCS-NINPT\WaveletSoftware');           %    小波包

addpath('C:\Users\zb\Desktop\PCS-NINPT\mywork');                          %    自编函数

%%  — — — — —  — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — —

%  测试图像选择 ( dataset11)

filename = 'lena';                               %    图像文件名（这样做的好处在于实验时更改方便）

% filename = 'barbara';                         %    图像文件名（这样做的好处在于实验时更改方便）

% filename = 'boats';                            %    图像文件名（这样做的好处在于实验时更改方便）

% filename = 'cameraman';                  %    图像文件名（这样做的好处在于实验时更改方便）

% filename = 'foreman';                       %    图像文件名（这样做的好处在于实验时更改方便）

% filename = 'house';                           %    图像文件名（这样做的好处在于实验时更改方便）

% filename = 'Monarch';                      %    图像文件名（这样做的好处在于实验时更改方便）
 
% filename = 'Parrots';                         %    图像文件名（这样做的好处在于实验时更改方便）

%  — — — — —  — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — —

%%  — — — — —  — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — —
%  参数设置

subrate=0.3;                                        %     欠采样率

a = 0.5;                                                 %     噪声控制因子

quantizer_bitdepth = 8;                       %     比特深度

num_trial = 1;                                       %     重复试验次数

num_levels = 3;                                    %     小波分解的水平数

max_iterations = 200;                           %     最大迭代次数
 
size_images = 256;                               %     图像维度，考虑方阵

total_pixels = size_images * size_images;          %    总像素个数

% 读取图像

original_filename = [ filename '.tif'];                                    %     存储图像变量

original_image = double (imread(original_filename));        %      读图像

[num_rows, num_cols] = size(original_image);                    %      计算图像的行和列

%%  加密阶段

%  注入噪声的NPT加密

%  生成一个注入的噪声信号

key_matrix = key_matrix_generate (num_rows, num_cols);

%  NPT加密矩阵 

NPT_model = NPTmodel (num_rows, num_cols); 

encrypted_image  = NINPT_encryption (original_image, num_rows, num_cols, a, key_matrix, NPT_model);

% decrypted_image  = NINPT_decryption (encrypted_image, num_rows, num_cols, a, key_matrix, NPT_model);

%%  压缩感知测量和重构

     %  测量矩阵生成
     
     M = round (subrate * num_rows);                                %    测量值个数
     
     Phi = orth (randn(size_images, size_images))';             %    生成测量矩阵

     Phi = Phi (1:M, :);  
     
     %  CS测量
              
     y =  Phi  *  encrypted_image;           %    测量值计算

 for k = 1: 1 : 1
     
  % KPA 分析 （估计测量矩阵）
  
      num_KPA =500;                                             %     明文密文对个数      
 
      x_KPA = randn (num_rows, num_KPA);         %      随机生成一个信号（明文）
    
      key_matrix_KPA = key_matrix_generate (num_rows, num_KPA);        
    
      NPT_model_KPA = NPTmodel (num_rows, num_KPA); 
   
   %  与明文对应的密文
   
   encrypted_x_KPA  = NINPT_encryption (x_KPA, num_rows, num_KPA, a,  key_matrix_KPA, NPT_model_KPA);
     
   y_KPA =  Phi  * encrypted_x_KPA;                     %     生成对应的测量矩阵 
     
  Phi_KPA = y_KPA * pinv (x_KPA);                       %     估计出的测量矩阵
  
 %  由于攻击者不知道NINPT的秘钥，攻击者随机猜测NINPT的秘钥对图像进行解密
   
  key_matrix_KPA_DE = key_matrix_generate (num_rows,  num_cols);
    
  NPT_model_KPA_DE = NPTmodel (num_rows,  num_cols); 
 
%  CS重构

reconstructed_image = PCS_PL_ED_Decoder (y, Phi_KPA, key_matrix_KPA_DE, NPT_model_KPA_DE, a, num_rows, num_cols, num_levels, max_iterations);

PSNR (k)= psnr(uint8(reconstructed_image), uint8(original_image));                     %    没有滤波的峰值信噪比
     
 end


   figure(1);
   
   imshow(uint8(reconstructed_image),'Border','tight');
%    
   
   figure(2);
%    
   imshow(uint8(encrypted_image),'Border','tight');
    

     
   figure(3);

 [Y_q, maxmum,  minmum]= quantization_255(y);                       %    测量值量化
   
   imshow(uint8(Y_q),'Border','tight');
   
 
  






    







