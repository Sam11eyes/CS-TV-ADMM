%   0-255量化

%  对测量值进行量化，量化后落在0-255范围

%  时间：2018年11月3日

function [Y_q, maxmum,  minmum]= quantization_255(Y)

[row, col] = size(Y);

maxmum = max(max(Y));
 
minmum = min(min(Y));
 
for i =1:1:row
    
    for j =1:1:col
        
        Y_q (i, j) = round( (255*(Y(i,j)-minmum))/(maxmum-minmum));
         
    end
    
end