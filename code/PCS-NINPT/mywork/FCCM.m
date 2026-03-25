function [ sequence ] = FCCM( x0, mu, v, h, n_iter ) 

    sequence = zeros([1 n_iter+1]);
    sequence(1) = x0;
    
    for i = 1:n_iter
        x = sequence(i);
        % 应用迭代公式
        new_x = mod(x + (h^v/gamma(1+v))*cos(mu*acos(x)), 2);
        sequence(i+1) = new_x;
    end

end