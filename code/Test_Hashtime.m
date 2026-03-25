a = 1 ;b = 1 ;c = 1 ;d = 2 ;%%四维维cat映射的参数

x01 =0.759; x02 =0.581;  %两个混沌矩阵的参数
mu1 = 6.372; mu2 = 7.687; 
    
    filename = 'lena';
    imname = [filename '.png'];
    grayImg = imread(imname);


   [hash,yfinal] = GetFinal(x01,x02,mu1,mu2,grayImg );


% 主计时循环
for k = 1:2000
    tic;
    hash_result = matrixHash_chaotic_Very2(yfinal, a, b, c, d, x01, mu1); % 调用目标函数
    execution_times(k) = toc;
end

% 转换为毫秒
execution_times_ms = execution_times * 1000;

% 计算统计数据
avg_time = mean(execution_times_ms);
max_time = max(execution_times_ms);
min_time = min(execution_times_ms);

% 显示结果（毫秒）
fprintf('运行时间统计（1500次循环）:\n');
fprintf('平均值 = %.4f ms\n', avg_time);
fprintf('最大值 = %.4f ms\n', max_time);
fprintf('最小值 = %.4f ms\n', min_time);