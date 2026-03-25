import socket
import time

def test_send(port=8887, delay=1):
    with socket.socket() as s:
        s.connect(('localhost', port))
        print(f"发送数据到MATLAB端口{port}")
        time.sleep(delay)
        s.sendall(b'0.85,0.67,0.91,0.74\n')
        print("数据发送完成")

if __name__ == '__main__':
    test_send()