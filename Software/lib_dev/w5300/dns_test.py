import socket

HOST = '208.67.222.222' # DNS server IP
PORT = 53  # DNS port

UDPClientSocket = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)

q = b''

# header
q = b'\x91\x92' # ID
q = q + b'\01\00' # FLAGS
q = q + b'\00\01' # QDCOUNT
q = q + b'\00\00' # ANCOUNT
q = q + b'\00\00' # NSCOUNT
q = q + b'\00\00' # ARCOUNT

# query
q = q + b'\07example\03com\00'
q = q + b'\00\01' # type: TYPE_A
q = q + b'\00\01' # class: CLASS_IN

print(q)

UDPClientSocket.sendto(q, (HOST, PORT))

data, address = UDPClientSocket.recvfrom(1024)
print(f"Reply from Server: {data}")