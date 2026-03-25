%  嵌入NINPT的并行压缩感知（解决CPA和KPA问题）

%  比较不同噪声水平条件下重构图像质量
  
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

filename = 'lena';                                  %    图像文件名（这样做的好处在于实验时更改方便）

% filename = 'barbara';                         %    图像文件名（这样做的好处在于实验时更改方便）

% filename = 'boats';                            %    图像文件名（这样做的好处在于实验时更改方便）

% filename = 'cameraman';                  %    图像文件名（这样做的好处在于实验时更改方便）

% filename = 'foreman';                       %    图像文件名（这样做的好处在于实验时更改方便）

% filename = 'house';                           %    图像文件名（这样做的好处在于实验时更改方便）

% filename = 'Monarch';                      %    图像文件名（这样做的好处在于实验时更改方便）
 
% filename = 'Parrots';                             %    图像文件名（这样做的好处在于实验时更改方便）

%  — — — — —  — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — —

%%  — — — — —  — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — —
%  参数设置

subrate=0.5;                                         %    欠采样率

quantizer_bitdepth = 8;                       %     比特深度

num_levels = 3;                                    %     小波分解的水平数

max_iterations = 200;                           %     最大迭代次数
 
size_images = 256;                               %     图像维度，考虑方阵

% 读取图像

original_filename = [ filename '.tif'];                                    %     存储图像变量

original_image = double (imread(original_filename));        %      读图像

[num_rows, num_cols] = size(original_image);                    %      计算图像的行和列

%  灰度映射操作

% for i=1:1:size_images
%     
%     for j =1:1:size_images
%         
%     mean_image (i, j)  =  128 ;
% 
%     end
%     
% end

% mean_encrypted_image_NPT = encrypted_image - mean_image;       %   灰度映射后的密文图像

% decrypted_image  = NINPT_decryption (encrypted_image, num_rows, num_cols, a, key_matrix, NPT_model);

%%  压缩感知测量和重构

 Noise_control_factor = 0 :0.1 :0.9;

 for k = 1: 1 : 10
     
     
     a = Noise_control_factor (k);

%  NINPT加密

%  生成一个注入的噪声信号

key_matrix = key_matrix_generate (num_rows, num_cols);

%  NPT加密矩阵 

NPT_model = NPTmodel (num_rows, num_cols); 

encrypted_image  = NINPT_encryption (original_image, num_rows, num_cols, a, key_matrix, NPT_model);
        
     %  测量矩阵生成
     
     M = round (subrate * num_rows);                                %    测量值个数
     
     Phi = orth (randn(size_images, size_images))';             %    生成测量矩阵

     Phi = Phi (1:M, :);  
     
     %  CS测量
    
     tic;
              
     y =  Phi  *  encrypted_image;           %    测量值计算
       
     toc;
     
%  CS重构

 initial = pinv(Phi) * y;

reconstructed_image = PCS_PL_ED_Decoder ( initial, y, Phi, key_matrix,  NPT_model , a, num_rows, num_cols, num_levels, max_iterations);


PSNRfinal (k) = psnr(uint8(reconstructed_image), uint8(original_image));                     %    没有滤波的峰值信噪比

    
 end


   figure(1);
   
   imshow(uint8(reconstructed_image),'Border','tight');
%    
   
   figure(2);
%    
   imshow(uint8(encrypted_image),'Border','tight');
   
   figure (3)
   
    
  plot(Noise_control_factor, PSNRfinal, 'r', 'LineWidth', 1.5);
   
   xlabel('Noise control factor')   
   
   ylabel('PSNR (dB)')   
  
   
 
  






    







