function matrix_server()
    % 创建TCP服务器，监听端口55000
    server = tcpserver("0.0.0.0", 55000, "ConnectionChangedFcn", @connectionCallback);
    disp('矩阵传输服务器已启动，等待客户端连接...');
    
    % 主循环控制
    server.UserData.keepRunning = true;
    
    while server.UserData.keepRunning
        pause(0.1);
        if ~isvalid(server)
            break;
        end
    end
    
    % 清理资源
    if isvalid(server)
        delete(server);
    end
    disp('服务器已关闭');
    
    function connectionCallback(src, ~)
        if src.Connected
            clientAddress = src.ClientAddress;
            disp(['客户端已连接，IP: ' clientAddress]);
            
            % 配置二进制数据传输模式
            configureCallback(src, "off"); % 先关闭回调
            
            try
                % 1. 生成测试矩阵 (154×256 double)
                matrixToSend = rand(154, 256);
                disp(['准备发送矩阵，大小: ' num2str(size(matrixToSend))]);
                
                % 2. 发送矩阵尺寸信息
                matrixSize = size(matrixToSend);
                write(src, int32(matrixSize), "int32");
                
                % 3. 发送矩阵数据
                write(src, matrixToSend(:), "double");
                disp('矩阵数据已发送');
                
                % 4. 等待客户端确认
                ack = read(src, 1, "uint8");
                if ack == 1
                    disp('客户端已成功接收矩阵');
                else
                    disp('客户端接收确认异常');
                end
                
            catch ME
                disp(['矩阵传输错误: ' ME.message]);
            end
            
            % 关闭连接
            delete(src);
            
        else
            disp('客户端断开连接');
            if isvalid(src)
                delete(src);
            end
        end
    end
end