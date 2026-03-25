function matrix_client()
    try
        % 连接服务器
        client = tcpclient("localhost", 55000, "Timeout", 10);
        disp('已连接到矩阵服务器');
        
        % 配置为二进制数据传输模式
        configureCallback(client, "off");
        
        % 1. 接收矩阵尺寸信息 (2个int32值)
        matrixSize = read(client, 2, "int32");
        disp(['服务器将发送矩阵，大小: ' num2str(matrixSize)]);
        
        % 检查尺寸是否为154×256
        if ~isequal(matrixSize, [154, 256])
            error('接收的矩阵尺寸不符合预期');
        end
        
        % 2. 接收矩阵数据
        data = read(client, 154 * 256, "double");
        receivedMatrix = reshape(data, 154, 256);
        disp('矩阵数据已接收');
        
        % 3. 发送确认信号
        write(client, uint8(1), "uint8");
        disp('已发送接收确认');
        
        % 4. 验证数据
        disp(['接收矩阵大小: ' num2str(size(receivedMatrix))]);
        disp(['矩阵示例值(1,1): ' num2str(receivedMatrix(1,1))]);
        disp(['矩阵示例值(154,256): ' num2str(receivedMatrix(154,256))]);
        
    catch ME
        disp(['矩阵接收错误: ' ME.message]);
        % 发送错误确认
        if exist('client', 'var') && isvalid(client)
            write(client, uint8(0), "uint8");
        end
    end
    
    % 清理资源
    if exist('client', 'var') && isvalid(client)
        clear client;
    end
    disp('连接已关闭');
end