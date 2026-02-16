import socket
import errno
import os

HOST = '104.18.2.24'    # The remote host
PORT = 80              # The same port as used by the server
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.setblocking(0)
    err = s.connect_ex((HOST, PORT))

    while(1):
        if err == 0: break
        print(errno.errorcode[err])
        err = s.getsockopt(socket.SOL_SOCKET, socket.SO_ERROR)
    
    while(1):
        try:
            s.send(b'')
            break
        except BlockingIOError:
            pass
    
    s.send(b'GET / HTTP/1.1\nHost:example.org\nConnection: close\n\n')
    lines = 0
    while(1):
        try:
            buf = s.recv(128)
            if len(buf):
                print('Received', buf)
            else: break
        except BlockingIOError:
            pass
    # data = s.recv(4096)
    # print('Received', repr(data))
    # data = s.recv(4096)
    # print('Received', repr(data))