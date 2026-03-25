function [Y, rk] = fn(m, n, k)

  P = orth(randn(m,k));
  
  Q = orth(randn(n,k))';
  
  Y = P * Q;
  
  rk = rank(Y);
  
end