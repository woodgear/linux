import socket

HOST = "0.0.0.0"  # Standard loopback interface address (localhost)
PORT = 8000  # Port to listen on (non-privileged ports are > 1023)
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))
    s.listen()
    while True:
        conn, addr = s.accept()
        with conn:
            print(f"Connected by {addr}")
            while True:
                data = conn.recv(1024)
                if not data:
                    break
                print("get data\n")
                response = b"HTTP/1.0 200 OK\r\n\r\nHello, World!"
                conn.sendall(response)
                break
            print("out\n")
    pass
