function NPT_model = NPTmodel (row, column,x02,mu2) 

v = 0.15;
h = 0.45;
T0 = 1000;
d = 10;

     phi1sequence = FCCM( x02, mu2 , v, h, d*256*256 );
     NPT_model = matrix(phi1sequence, d, row, column);
     Pmean = mean(NPT_model(:));

for i= 1: row
    
   for j = 1: column
        

        
        if NPT_model  (i, j) >  Pmean
            
           NPT_model  (i, j) =  0;
           
        else
            
          NPT_model  (i, j) = 1;
          
        end
        
   end
    
end

end