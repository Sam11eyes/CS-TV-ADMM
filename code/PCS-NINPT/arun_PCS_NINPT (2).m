%  嵌入NINPT的并行压缩感知（解决KPA问题）

%  A test example
  
%  编程人：张  波

%  修订：  2020年12月31日

%  单位：  固定通信系信息通信系统教研室

clc;

clear;

%  将需要的数据加入路径

%addpath('C:\Users\zb\Desktop\PCS-NINPT\dataset11');                       %     原图

%addpath('C:\Users\zb\Desktop\PCS-NINPT\WaveletSoftware');           %    小波包

%addpath('C:\Users\zb\Desktop\PCS-NINPT\mywork');                          %    自编函数

%%  — — — — —  — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — —

%  测试图像选择 ( dataset11)

filename = 'lena';                                  %    图像文件名（这样做的好处在于实验时更改方便）

% filename = 'barbara';                         %    图像文件名（这样做的好处在于实验时更改方便）

% filename = 'boats';                            %    图像文件名（这样做的好处在于实验时更改方便）

% filename = 'cameraman';                  %    图像文件名（这样做的好处在于实验时更改方便）

% filename = 'foreman';                       %    图像文件名（这样做的好处在于实验时更改方便）

% filename = 'house';                           %    图像文件名（这样做的好处在于实验时更改方便）

% filename = 'Monarch';                      %    图像文件名（这样做的好处在于实验时更改方便）
 
% filename = 'Parrots';                         %    图像文件名（这样做的好处在于实验时更改方便）

%  — — — — —  — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — —

%%  — — — — —  — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — —
%  参数设置

x01 =0.759; x02 =0.581; x03 =0.652; x04 =0.385; 
mu1 = 6.372; mu2 = 7.687; mu3 = 5.193; mu4 = 6.471; 
v = 0.15;
h = 0.45;
T0 = 1000;
d = 10;

subrate=0.5;                                         %     欠采样率

a = 0;                                                    %     噪声控制因子

quantizer_bitdepth = 6;                       %     比特深度

num_trial = 1;                                       %     重复试验次数

num_levels = 3;                                    %     小波分解的水平数

max_iterations = 5;                           %     最大迭代次数
 
size_images = 256;                               %     图像维度，考虑方阵

size_down_images = 32;

total_pixels = size_images * size_images;          %    总像素个数

% 读取图像

original_filename = [ filename '.png'];                                    %     存储图像变量

original_image = double (imread(original_filename));        %      读图像

[num_rows, num_cols] = size(original_image);                    %      计算图像的行和列

downsamping_image = imresize(imread(original_filename), [size_down_images size_down_images]);      %    获得欠采样子图

interpolated_image = double (imresize(downsamping_image, [size_images size_images], 'bilinear'));       %    获得插值图像

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


% % 随机模矩阵
% 
% key_matrix = key_matrix_generate (num_rows, num_cols);
% 
% %  模加密
% 
% encrypted_image = mod_encrypting  (original_image, key_matrix, size_images);
% 

%  模解密

% decrypted_image = mod_decrypting (encrypted_image, key_matrix, size_images);

%  灰度映射操作

mean =mean (encrypted_image (:) );

for i=1:1:size_images
    
    for j =1:1:size_images
        
    mean_image (i, j)  =  mean;

    end
    
end

% mean_encrypted_image = encrypted_image - mean_image;       %   灰度映射后的密文图像

% decrypted_image  = NINPT_decryption (encrypted_image, num_rows, num_cols, a, key_matrix, NPT_model);

%%  压缩感知测量和重构

 for k = 1: 1 : 1
           
     subrate = 0.6;
        
     %  测量矩阵生成
     
     %M = round (subrate * num_rows);                                %    测量值个数
     
     %Phi = orth (randn(size_images, size_images))';             %    生成测量矩阵

     %Phi = Phi (1:M, :);  
     
     phi1sequence = FCCM( x01, mu1 , v, h, d*154*256 );
     Phi = matrix(phi1sequence, d, 154, 256);

     %  CS测量
    
     tic;
              
     y =  Phi  *  encrypted_image;                        %    测量值计算
     
     y_mean =  Phi  *  mean_image;                        %    测量值计算
     
     y_diff = y - y_mean;
       
     toc;    
     

%  测量值量化


[y_sq, rate_sq] = SQ_Coding (y_diff, quantizer_bitdepth, num_rows, num_cols);                    %   普通熵编码

yfinal = y_sq + y_mean;


%  CS重构

toc;

reconstructed_image = PCS_PL_ED_Decoder (yfinal, Phi, key_matrix,  NPT_model , a, num_rows, num_cols, num_levels, max_iterations);

% reconstructed_image = PCS_PL_ED_Decoder_mod (yfinal, interpolated_image, Phi, key_matrix, num_rows, num_cols, num_levels, max_iterations);
   toc;  

% [PSNR, reconstructed_image]  = ...
%     PCS_PL_ED_Decoder_shoulian (y, original_image, 1, Phi, key_matrix, NPT_model, a, num_rows, num_cols, num_levels, 500);
 
PSNRfinal (k) = psnr(uint8(reconstructed_image), uint8(original_image));                     %    没有滤波的峰值信噪比

rate (k) = rate_sq;                     %    没有滤波的峰值信噪比


     
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

   
%    figure (4)
%    
%   plot(times, R25, 'r', 'LineWidth', 1.5);
%    
%    xlabel('Compression ratio')   
%    
%    ylabel('PSNR (dB)')   
%   
%    legend('mu=10','mu=15','mu=20','mu=25');
   




  

    







