%  求梯度方向

function derivative_of_TV = derivating_of_TV (image, size_images)


N = size_images;             %      图像矩阵维度

q = 10^-7;

% 读取图像，并将图像调整至指定大小

original_image = image;

X = zeros(N+2,N+2);

for i = 1:1:N
    
    for j = 1:1:N
        
        X(i+1,j+1) = original_image(i, j);
        
    end
    
end

for j=1:1:N+2
    
    X(1, j) =   X(2, j) ;
    
    X(N+2, j) =   X(N+1, j) ;
    
end

for i=1:1:N+2
    
    X(i, 1) =   X(i, 2) ;
    
    X(i, N+2) =   X(i, N+1) ;
    
end

Y = zeros(N+2,N+2);     

for i=2:1:N+1
    
    for j=2:1:N+1
        
        Y(i, j) = (2*X(i, j)-X(i-1, j)-X(i, j-1))/(sqrt((X(i, j)-X(i-1, j))^2+(X(i, j)-X(i, j-1))^2)+q)+(X(i, j)-X(i+1, j))/(sqrt((X(i+1, j)-X(i, j))^2+(X(i+1, j)-X(i+1, j-1))^2)+q)+(X(i, j)-X(i, j+1))/(sqrt((X(i, j+1)-X(i, j))^2+(X(i, j+1)-X(i-1, j+1))^2)+q);
        
           end
    
end
    
Z = zeros(N,N); 

    for i = 1:1:N
    
    for j = 1:1:N
        
        Z(i,j) = Y (i+1, j+1);
        
    end
    
    end

    derivative_of_TV = Z;
    
    
    
    
    
    