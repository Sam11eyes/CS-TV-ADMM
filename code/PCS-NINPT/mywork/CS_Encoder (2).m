% 该函数用于完成CS测量值计算
% 参数说明
% current_image：要测量的二维信号
% Phi:测量矩阵


function y = CS_Encoder(current_image, Phi)

[M, N] = size(Phi);          %  测量矩阵行列数
 
block_size = sqrt(N);       %  分块的大小

[num_rows, num_cols] = size(current_image);       %   图像的行列数

x = im2col(current_image, [block_size block_size], 'distinct');    %  将子块按列排列 

y = Phi * x;     %  CS测量
