%%终端设备

function [hash,reimage] = IOTServer(app)
    if isPortInUse(55000)
        hash = "";
        reimage = [];
        return;
    end
    x01 = app.parasite1.Value;
    mu1 = app.parasite2.Value;
    x02 = app.parasite3.Value;
    mu2 = app.parasite4.Value;

    % 创建TCP服务器，监听端口55000

    server = tcpserver("0.0.0.0", 55000, "Timeout", 30, "ConnectionChangedFcn", @connectionCallback);
    disp('接收服务器已启动，等待客户端连接...');

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
            
                       
                %% 第一阶段：接收矩阵
                disp('等待接收矩阵尺寸信息...');
                matrixSize = read(src, 2, "int32");
                disp(['将接收矩阵，大小: ' num2str(matrixSize)]);
                
                % 检查尺寸是否为154×256
                if ~isequal(matrixSize, [154, 256])
                    error('接收的矩阵尺寸不符合预期');
                end
             
 

                % 接收矩阵数据
                disp('开始接收矩阵数据...');
                data = read(src, 154 * 256, "double");
                receivedMatrix = reshape(data, 154, 256);
                disp('矩阵数据接收完成');
                
                reimage = EncodeFinal(receivedMatrix,x01,x02,mu1,mu2);


                % 验证矩阵
                disp(['接收矩阵大小: ' num2str(size(receivedMatrix))]);
                disp(['矩阵示例值(1,1): ' num2str(receivedMatrix(1,1))]);
                disp(['矩阵示例值(154,256): ' num2str(receivedMatrix(154,256))]);
                
                % 发送最终确认
                write(src, uint8(1), "uint8");
                disp('已发送最终确认');

                a = 1 ;b = 1 ;c = 1 ;d = 2 ;
                hash = read(src, 32, "char");
                TestHash = logicalToHex(matrixHash_chaotic_Very2(int8(receivedMatrix),a,b,c,d,x01,mu1));
                
                if ~strcmp(hash,TestHash)
                    hash = "图像已经被篡改";
                end

            % 关闭连接
            if isvalid(src)
                delete(src);
            end
            
            try
                ... % 原有矩阵接收逻辑不变
                
                %% 增加心跳检测机制
                % 每10秒发送一次心跳包
                configureCallback(src, "off");
                lastHeartbeat = tic;
                while isvalid(src) && src.Connected
                    % 检查超时（15秒无数据）
                    if toc(lastHeartbeat) > 15
                        error('心跳超时，连接可能已断开');
                    end

                    %  模拟心跳包（实际可定期发送空数据包）
                    pause(0.1); 
                end
                
            catch ME
                %%  异常处理（记录日志）
                disp(['服务器处理错误: ' ME.message]);
                if isvalid(src)
                    delete(src);
                end
            end


        else
            disp('客户端断开连接');
            if isvalid(src)
                delete(src);
            end
        end
    end
end


function hexStr = logicalToHex(logicalVec)
    % 验证输入是否为128位逻辑向量
    if ~islogical(logicalVec) || numel(logicalVec) ~= 128
        error('输入必须是128位逻辑向量');
    end
    
    % 将逻辑向量转为二进制字符串（无空格）
    binStr = sprintf('%d', logicalVec);
    
    % 补齐长度至4的倍数（128已是4的倍数，可跳过）
    if mod(length(binStr), 4) ~= 0
        binStr = [repmat('0', 1, 4 - mod(length(binStr), 4)), binStr];
    end
    
    % 每4位一组转换为十六进制字符
    hexStr = '';
    for i = 1:4:length(binStr)
        quad = binStr(i:i+3);                % 取4位二进制
        decVal = bin2dec(quad);               % 转为十进制（0-15）
        hexChar = dec2hex(decVal);            % 转为单字符十六进制
        hexStr = [hexStr, hexChar];           % 拼接结果
    end
end

function result = isPortInUse(port)
    % 检查端口是否被占用
    result = false;
    try
        % 尝试创建一个临时服务器来测试端口
        tempServer = tcpserver("0.0.0.0", port);
        delete(tempServer);
    catch
        result = true;
    end
end
