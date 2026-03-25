%  生成测量矩阵
% function Phi = BCS_SPL_GenerateProjection(block_size, subrate, filename)

%  参数说明
%  block_size： 分块大小
%  subrate：欠采样速率
%  filename：非必须，只是为了存储方便



function Phi = GenerateProjection(block_size, subrate, filename)

N = block_size * block_size;        %  分块的元素个数
M = round(subrate * N);             %  测量值个数

if ((nargin == 3) && exist(filename, 'file'))
    load(filename);
else
  Phi = orth(randn(N, 2 * N))';        %  生成测量矩阵
end

if ((nargin == 3) && (~exist(filename, 'file')))
  save(filename, 'Phi');          % 存储测量矩阵（方便后续调用）
end

Phi = Phi(1:M, :);
