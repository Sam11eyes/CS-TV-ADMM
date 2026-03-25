
function key_matrix = key_matrix_generate2 (row, column)

key_matrix = zeros(row, column);      %   模矩阵

gravel_level =255;                                                   %   灰度值范围

for i = 1: row
    
    for j = 1: column
        
        rand_vector = randperm(gravel_level);
        
        rand_number = rand_vector (1);
                
       key_matrix(i, j) = rand_number;
       
    end
    
end

end