function  IOTClientGetParams(app)
    port = 8887;
    % 创建TCP服务器对象
    server = tcpserver("localhost", port, "ConnectionChangedFcn", @connectionCallback);
    
    % 设置数据回调函数（当有数据到达时触发）
    configureCallback(server, "terminator", @(src, ~) readDataFcn(src,app));
    
    fprintf('TCP服务器已在端口 %d 启动，等待连接...\n', port);
    
    % 保持服务器运行
    while true
        pause(0.1); % 减少CPU占用
        if ~isvalid(server)
            break; % 如果服务器被关闭则退出
        end
    end
end

function connectionCallback(src, ~)
    if src.Connected
        fprintf('客户端已连接 [%s]\n', datetime);
    else
        fprintf('客户端断开连接 [%s]\n', datetime);
    end
end

function readDataFcn(src,app)
    % 读取所有可用数据
    data = read(src, 29, "string");
    
    % 显示接收信息
    fprintf('收到 %d 字节数据 [%s]\n', strlength(data), datetime);
    
    % 处理数据（转换为数值数组）
    try
        values = sscanf(data, '%f,')';  % 转换为行向量
        disp('解析后的数据：');
        disp(values);
        
        app.parasite1.Value = values(1);
        app.parasite2.Value = values(2);
        app.parasite3.Value = values(3);
        app.parasite4.Value = values(4);

        disp(datestr(now));

        
    catch ME
        fprintf('数据解析错误: %s\n', ME.message);
    end
end