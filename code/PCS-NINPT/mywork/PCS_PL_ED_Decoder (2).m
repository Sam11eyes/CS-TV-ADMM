% 



function reconstructed_image = ...
    PCS_PL_ED_Decoder (y, Phi, key_matrix, NPT_model, a, num_rows, num_cols, num_levels, max_iterations)

lambda = 6;

if (nargin < 6)
  max_iterations = 100;
end

% set level to have maximum wavelet expansion
if (nargin < 5)
	if floor(log2(num_rows)) < floor(log2(num_cols))
		num_levels = floor(log2(num_rows)) - 3;
	else
		num_levels = floor(log2(num_cols)) - 3;
	end
end

TOL = 0.0001;%精度
D_prev = 0;

pinvPhi = pinv (Phi);

x = pinvPhi * y;      %  初始化



for i = 1:max_iterations
    
    i
  [x, D] = SPLIteration(y, x, Phi, pinvPhi, key_matrix, NPT_model, a, num_rows, num_cols, ...
      lambda, num_levels);

%   if ((D_prev ~= 0) && (abs(D - D_prev) < TOL))
%     break;
%   end

  D_prev = D;
  
end



  [x , ~] = SPLIteration(y, x, Phi, pinvPhi, key_matrix, NPT_model, a, num_rows, num_cols, ...
      lambda, num_levels, 'last'); 

     figure(2);
   imshow(uint8(x),'Border','tight');


reconstructed_image  = NINPT_decryption (x, num_rows, num_cols, a, key_matrix, NPT_model);






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [x, D] = SPLIteration(y, x, Phi, pinvPhi, key_matrix, NPT_model, a, num_rows, num_cols, ...
    lambda, num_levels, last)

if (exist('nor_dualtree.mat'))
  load nor_dualtree
else
  normaliz_coefcalc_dual_tree
end

[Faf, Fsf] = AntonB;
[af, sf] = dualfilt1;


% r = 0.8;                                    %    梯度投影步长

x1 = x;                                         %    记录上一轮密文域图像估计值

r= 0.8;

x_hat = x; 

%  1：阈值收缩前进行加密反变换（回到图像域）

x_hat  = NINPT_decryption (x_hat, num_rows, num_cols, a, key_matrix, NPT_model);

% x_hat = wiener2(x_hat, [3, 3]);

%  2: TV投影

% x_hat  = x_hat - r * derivating_of_TV(x_hat, num_rows);                  %     梯度投影
% 
%  x_bar = x_hat;

% %  3：DDWT阈值收缩

x_check = normcoef (cplxdual2D(symextend(x_hat, 2^(num_levels - 1)), ...
    num_levels, Faf, af), num_levels, nor);

if (nargin == 9)
  end_level = 1;
else
  end_level = num_levels - 1;
end
x_check = SPLBivariateShrinkage(x_check, end_level, lambda);

x_bar = icplxdual2D(unnormcoef(x_check, num_levels, nor), num_levels, Fsf, sf);

Irow = (2^(num_levels - 1) + 1):(2^(num_levels - 1) + num_rows);

Icol = (2^(num_levels - 1) + 1):(2^(num_levels - 1) + num_cols);

x_bar = x_bar(Irow, Icol);            %  阈值收缩后估计的图像


%  解空间投影

x_bar  = NINPT_encryption (x_bar, num_rows, num_cols, a, key_matrix, NPT_model);

x = x_bar + pinvPhi * (y - Phi * x_bar);                      %    密文域投影

  
D = RMS(x, x1);
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function x_check = SPLBivariateShrinkage(x_check, end_level, lambda)

windowsize  = 3;
windowfilt = ones(1, windowsize)/windowsize;

tmp = x_check{1}{1}{1}{1};
Nsig = median(abs(tmp(:)))/0.6745;

for scale = 1:end_level
  for dir = 1:2
    for dir1 = 1:3
      Y_coef_real = x_check{scale}{1}{dir}{dir1};
      Y_coef_imag = x_check{scale}{2}{dir}{dir1};
      Y_parent_real = x_check{scale+1}{1}{dir}{dir1};
      Y_parent_imag = x_check{scale+1}{2}{dir}{dir1};
      Y_parent_real  = expand(Y_parent_real);
      Y_parent_imag  = expand(Y_parent_imag);
      
      Wsig = conv2(windowfilt, windowfilt, (Y_coef_real).^2, 'same');
      Ssig = sqrt(max(Wsig-Nsig.^2, eps));
      
      T = sqrt(3)*Nsig^2./Ssig;
      
      Y_coef = Y_coef_real + sqrt(-1)*Y_coef_imag;
      Y_parent = Y_parent_real + sqrt(-1)*Y_parent_imag;
      Y_coef = bishrink(Y_coef, Y_parent, T*lambda);
      
      x_check{scale}{1}{dir}{dir1} = real(Y_coef);
      x_check{scale}{2}{dir}{dir1} = imag(Y_coef);
    end
  end
end
