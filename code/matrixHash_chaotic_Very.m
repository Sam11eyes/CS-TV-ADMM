function hash = matrixHash_chaotic_Very(matrix,a,b,c,d,x0,u0)

hash = zeros(1,128,"logical");


bits = zeros(size(matrix, 1), size(matrix, 2), 8,"logical"); % 预分配内存
for i = 1:8
    bits(:, :, i) = bitget(matrix, i); % 提取第i位
end
bitstream = reshape(bits, 1, []); 

bisblock = reshape(bitstream,2464, 128);


for i = 1:2464   %%分成2564组 
    test = reshape(bisblock(i,1:128),16,8);
    int8Values = uint8(test * [128; 64; 32; 16; 8; 4; 2; 1]); %%转换到int8
    wr = u0/2 + double(int8Values)/1024;   %%映射到0到0.5
    %把这16个分成四个小组
    x = [x0,x0,x0,x0];
    for j = 1:4
        %给pwlcm分配参数
        pwlcm_parasite = [wr((j-1)*4+1),wr((j-1)*4+2),wr((j-1)*4+3),wr((j-1)*4+4),wr((j-1)*4+4),wr((j-1)*4+3),wr((j-1)*4+2),wr((j-1)*4+1),u0,u0];
        for k = 1:10
            x(j) = pwlcm(x(j),pwlcm_parasite(k));
        end
    end
    x = cat4d(x,a,b,c,d, 2);  %%四维cat映射

    key_sequence = [extract_bits(x(1), 32), extract_bits(x(2), 32), extract_bits(x(3), 32), extract_bits(x(4), 32);];
    hash = bitxor(key_sequence,hash);
    hash = bitxor(bisblock(i,1:128),hash);
end


end

function y = pwlcm(x, P)
    if x>=0 && x<P
        y=x/P;
    end
    if x>=P && x<0.5
        y=(x-P)/(0.5-P);
    end
    if x>=0.5 && x<1-P
        y=(1-P-x)/(0.5-P);
    end
    if x>=1-P && x<1
        y=(1-x)/P;
    end   

end

function state = cat4d(x,a,b,c,d, iterations)

% 定义转换矩阵 (基于参数 a=1, b=1, c=1, d=2)
C = [a, b, 0, 0;
     c, d, 0, 0;
     0, 0, a, b;
     0, 0, c, d];

state = x';

% 迭代计算
for i = 1:iterations
    % 矩阵乘法
    state = mod(C * state,1);
end
state = state';

end

function bit_array = extract_bits(value, num_bits)
% 从浮点数的小数部分提取指定数量的比特（返回logical数组）
% 输入:
%   value: 浮点数 (0~1之间)
%   num_bits: 要提取的比特数 (如32)
% 输出:
%   bit_array: logical数组 (true=1, false=0)

% 初始化逻辑数组
bit_array = false(1, num_bits); % 创建1×num_bits的false数组

if value == 0
    return; % 直接返回全false
end

temp = value;
for i = 1:num_bits
    temp = temp * 2;          % 乘以2
    bit_val = (temp >= 1);    % 直接得到逻辑值 (true=1, false=0)
    bit_array(i) = bit_val;   % 存储到逻辑数组
    
    % 更新小数部分
    if bit_val
        temp = temp - 1;
    end
end
end
