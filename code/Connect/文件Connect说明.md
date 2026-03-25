文件说明2：

Connect：主要是负责服务器之间的信息传输

​	a. 其中 IOTClientGetParams 与 IOTSeverGetParams 函数用于接受来自云服务器发送的参数。这个两个函数在app启动的时候调用的，在服务器结束之前会一直监听接受新的密钥。

​	b. IOTClient 与 IOTSever 是用于边缘服务器和终端服务器的信息传输，主要是传输矩阵和hash。

​	c.其他的函数不重要，是之前测试使用的函数

