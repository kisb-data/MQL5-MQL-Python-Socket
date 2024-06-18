import socket

class SocketServer:
    def __init__(self, address = '', port = 9090):
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.address = address
        self.port = port
        self.sock.bind((self.address, self.port))
        self.cummdata = ''
        
    def SendReceive(self, to_send):
        self.sock.listen(1)
        self.conn, self.addr = self.sock.accept()
        self.cummdata = ''

        while True:
            data = self.conn.recv(10000)
            self.cummdata+=data.decode("utf-8")
            if not data:
                break    
            self.conn.send(bytes(to_send, "utf-8"))
            return self.cummdata
            
    def __del__(self):
        self.sock.close()
    