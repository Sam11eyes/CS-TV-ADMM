clc;

clear;

mu_values = 2:0.01:8;
n_iter = 1000;
hold on;
for mu = mu_values
    seq = FCCM(0.2345, mu, 0.15, 0.45, n_iter);
    plot(mu*ones(100), seq(end-99:end), '.k', 'MarkerSize',1);
end


% 1. 生成混沌序列 (示例)
key_matrix = key_matrix_generate(256, 256);
key = key_matrix(:);

% 2. 计算李雅普诺夫指数谱
[lyap_spectrum, final_lyap] = calculate_lyapunov_spectrum(key);

% 3. 分析结果
% 最大李雅普诺夫指数
max_lyap = max(final_lyap);
fprintf('最大李雅普诺夫指数: %.4f\n', max_lyap);
if max_lyap > 0
    fprintf('系统表现出混沌行为\n');
else
    fprintf('系统未表现出混沌行为\n');
end


function [lyap_spectrum, final_lyap] = calculate_lyapunov_spectrum(key)
    % 输入参数:
    % key - 混沌序列 (256x256矩阵展开的列向量)
    % 输出参数:
    % lyap_spectrum - 李雅普诺夫指数谱 (随时间演化)
    % final_lyap - 最终收敛的李雅普诺夫指数值
    
    % 1. 参数设置
    emb_dim = 10;       % 嵌入维度 (根据Takens定理，应至少为2D+1)
    tau = 1;            % 延迟时间 (可尝试自相关函数确定)
    evolution_steps = min(1000, floor(length(key)/10)); % 演化步数
    min_neighbors = 20; % 最小邻居数
    
    % 2. 数据预处理
    key = key - mean(key); % 去中心化
    key = key / std(key);  % 归一化
    
    % 3. 相空间重构 (使用延迟坐标嵌入)
    N = length(key);
    M = N - (emb_dim-1)*tau;
    Y = zeros(M, emb_dim);
    for i = 1:emb_dim
        Y(:,i) = key((1:M)+(i-1)*tau);
    end
    
    % 4. 初始化李雅普诺夫指数计算
    lyap = zeros(emb_dim, evolution_steps);
    Q = eye(emb_dim);   % 初始正交基
    
    % 5. 主循环 - 计算局部Jacobian和演化切线空间
    for i = 1:evolution_steps
        % 随机选择参考点 (避免边界问题)
        ref_idx = randi([1, M-emb_dim]);
        ref_point = Y(ref_idx, :)';
        
        % 寻找最近邻点 (使用k近邻)
        distances = sqrt(sum((Y - ref_point').^2, 2));
        [~, neighbors] = sort(distances);
        neighbors = neighbors(2:min_neighbors+1); % 排除自身
        
        % 计算局部线性化近似 (Jacobian估计)
        delta_X = Y(neighbors,:) - ref_point';
        delta_Y = Y(neighbors+1,:) - Y(ref_idx+1,:);
        J = pinv(delta_X) * delta_Y; % 最小二乘估计
        
        % 演化切线空间
        Q = J * Q;
        
        % QR分解 (保持正交性)
        [Q, R] = qr(Q);
        
        % 记录李雅普诺夫指数
        for k = 1:emb_dim
            lyap(k, i) = lyap(k, max(i-1,1)) + log(abs(R(k,k)));
        end
    end
    
    % 6. 计算最终结果
    lyap_spectrum = lyap ./ (1:evolution_steps);
    final_lyap = lyap(:,end) / evolution_steps;
    
    % 7. 结果可视化
    figure;
    plot(1:evolution_steps, lyap_spectrum', 'LineWidth', 1.5);
    xlabel('演化步数');
    ylabel('李雅普诺夫指数');
    title('混沌序列的李雅普诺夫指数谱');
    grid on;
    
    % 显示最终结果
    fprintf('最终李雅普诺夫指数谱:\n');
    for k = 1:emb_dim
        fprintf('λ%d = %.4f\n', k, final_lyap(k));
    end
end