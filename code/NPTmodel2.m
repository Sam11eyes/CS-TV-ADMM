function NPT_model = NPTmodel2 (row, column) 

for i= 1: row
    
   for j = 1: column
        
        Permutation = randperm (2); 
        
        if Permutation (1) ==1
            
           NPT_model  (i, j) =  0;
           
        else
            
          NPT_model  (i, j) = 1;
          
        end
        
   end
    
end

end