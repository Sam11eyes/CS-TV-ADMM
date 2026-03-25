function [hash,matrixToSend] = IOTClient(x01,mu1,x02,mu2,file)
    %  新增断网重连参数
    maxRetries = 5;             % 最大重试次数
    retryInterval = 2;           % 初始重连间隔（秒）
    retryCount = 0;              % 当前重试计数
    success = false;             % 操作成功标志
    
    %  断网重连主循环
    while retryCount <= maxRetries && ~success
        try
            % 连接服务器
            client = tcpclient("localhost", 55000, "Timeout", 10);
            disp('已连接到服务器');
            
            % 配置为二进制数据传输模式
            configureCallback(client, "off");
            
            %% 第一阶段：发送矩阵
            %  每次重连都重新生成数据（确保数据最新）
            [hash,matrixToSend] = GetFinal(x01,x02,mu1,mu2,file); 
            disp(['准备发送加密图片，大小: ' num2str(size(matrixToSend))]);
            
            % 攻击者篡改
            %matrixToSend(1) = 1;

            % 1. 发送矩阵尺寸
            write(client, int32(size(matrixToSend)), "int32");
            
            % 2. 发送矩阵数据
            write(client, matrixToSend(:), "double");
            disp('矩阵数据已发送');
            
            % 3. 等待服务器最终确认
            finalAck = read(client, 1, "uint8");
            if finalAck == 1
                disp('服务器已成功接收矩阵');
            else
                error('服务器接收矩阵时出现错误'); % 
            end
            
            % 4. 发送哈希值
            write(client, hash, 'int8');
            disp('哈希值已发送');
            
            success = true; % 
            
        catch ME
            %%  断网重连处理
            disp(['通信错误: ' ME.message]);
            retryCount = retryCount + 1;
            
            if retryCount <= maxRetries
                waitTime = retryInterval * (2^(retryCount-1));
                disp(['将在 ' num2str(waitTime) ' 秒后重试 (尝试 ' num2str(retryCount) '/' num2str(maxRetries) ')']);
                pause(waitTime);
            else
                error('达到最大重连次数，放弃连接'); %  终止重连
            end
            
            % 清理无效连接
            if exist('client', 'var') && isvalid(client)
                clear client;
            end
        end
    end
    
    %  最终资源清理
    if exist('client', 'var') && isvalid(client)
        clear client;
    end
    disp('连接已关闭');
end