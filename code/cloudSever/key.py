import time
import socket
import mysql.connector
from mysql.connector import Error

# 替换为你的数据库实际连接信息
DB_CONFIG = {
    'host': 'localhost',      # 数据库主机地址（图中为localhost）
    'port': 3306,             # MySQL默认端口
    'user': 'root',           # 替换为你的数据库用户名
    'password': '123456',  # 替换为你的数据库密码
    'database': 'user_auth'   # 图中数据库名
}

# TCP发送配置
TCP_PORT1 = 8887               # 选择一个端口（图中未显示，可自定义）
TCP_PORT2 = 8886
BUFFER_SIZE = 1024

# ==================== 核心函数 ====================
def generate_values(timestamp: float, password: str) -> tuple:

    import hashlib
    # 1. 使用时间戳和密码创建混沌系统的初始种子值
    seed_str = f"{password}{timestamp}"
    seed_hash = hashlib.sha256(seed_str.encode()).hexdigest()
    
    # 2. 将哈希值的前16个字符转换为0到1之间的初始值
    seed_val = int(seed_hash[:16], 16) / (16**16)  # 16^16 = 2^64
    x0 = 0.1 + 0.8 * (seed_val % 1)  # 映射到0.1-0.9范围内避免边界问题
    
    # 3. 将哈希值的后16个字符转换为混沌参数r (3.57-4.0之间)
    r_val = int(seed_hash[16:32], 16) / (16**16)
    r = 3.57 + 0.43 * (r_val % 1)  # 混沌参数范围3.57-4.00
    
    # 4. 混沌系统迭代1000次（预热）
    x = x0
    for _ in range(1000):
        x = r * x * (1 - x)  # Logistic映射方程
    
    # 5. 再迭代4次获取结果值
    values = []
    for _ in range(4):
        x = r * x * (1 - x)
        # 将结果值映射到0.5-1.0范围
        values.append( 0.5 * (x % 1))
    
    return tuple(values)


def format_to_bytes(data):

    # 将每个数字格式化为两位小数的字符串
    formatted = ",".join(f"{x:.4f}" for x in data)
    
    # 添加换行符并转换为字节串
    return (formatted + "\n").encode("utf-8")

def send_via_tcp(ip: str, data: list, form: bool) -> bool:
    """
    通过TCP发送浮点数列表到指定IP
    """

    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.settimeout(3.0)  # 设置3秒超时
            if form == 0:
                s.connect((ip, TCP_PORT1))
                
            if form == 1:
                s.connect((ip, TCP_PORT2))

            # 将浮点数转为字符串发送，用逗号分隔
            s.sendall(format_to_bytes(data))
            return True
    except Exception as e:
        print(f"发送到 {ip} 失败: {str(e)}")
        return False

# ==================== 主流程 ====================
try:
    # 连接数据库
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor(dictionary=True)
    
    # 查询用户数据
    cursor.execute("SELECT username, password, iot_client, iot_server FROM user")
    users = cursor.fetchall()
    
    print(f"找到 {len(users)} 个用户")
    for user in users:
        print(f"\n处理用户:  {user['username']}")
        # 生成时间戳
        current_timestamp = time.time()
        
        # 生成四个值 (参数: 时间戳 + 数据库密码字段)
        values = generate_values(current_timestamp, user['password'])
        print(f"生成值: {values}")
        
        # 获取目标IP地址
        targets = [user['iot_client'], user['iot_server']]
        i = 0
        # 分别向两个IP发送
        for target_ip in targets:
            print(f"发送到 {target_ip}...")
            if send_via_tcp(target_ip, values,i):
                print("发送成功")
            i = i+1
                
except Error as e:
    print(f"数据库错误: {str(e)}")
finally:
    if 'conn' in locals() and conn.is_connected():
        cursor.close()
        conn.close()