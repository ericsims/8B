import socket

HOST = '104.18.2.24'    # The remote host
PORT = 80              # The same port as used by the server
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.connect((HOST, PORT))
    s.sendall(b'GET / HTTP/1.1\nHost:example.org\nConnection: close\n\n')
    data = s.recv(4096)
    print('Received', repr(data))
    data = s.recv(4096)
    print('Received', repr(data))