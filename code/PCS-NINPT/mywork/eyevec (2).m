% 生成一个单位向量
% 编程人：张波
% 单位：重庆通信学院DSP研究室
% 时间：2013年10月28日

function A=eyevec(N,index)
A=zeros(N,1);
A(index)=1;
end