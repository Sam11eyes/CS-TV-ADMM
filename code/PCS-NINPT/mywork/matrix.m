function [Phi1] = matrix(Q, d, M, N)

    num_elements = d * M *N;

    selected_Q = Q(1:d:num_elements);
    W = 1 -  mod(selected_Q, 1);
    required_length = M*N;

    W = W(1:required_length);
    W_matrix = reshape(W, [M, N]);
    
    Phi1 = sqrt((0.7)/M) * W_matrix;
end