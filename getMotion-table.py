import socket
import binascii
from time import sleep

target_host = "DVR.url" 
target_port = 80  # create a socket object 
target_auth= "eqqjgGFJGJGJ323dq3=="

client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)  

message = "POST /cgi-bin/supervisor/NetworkBk.cgi HTTP/1.1\r\nHost: security.lan:90\r\n"
message += "Connection: keep-alive\r\nAccept-Encoding: gzip, deflate\r\nAccept: */*\r\n"
parameters = "list_num=4&command=latest&list_type=MOTION&action=query&type=search_list&hdd_num=1"
contentLength = "Content-Length: " + str(len(parameters)) + "\r\n"
contentType = "Content-Type: application/x-www-form-urlencoded\r\nUser-Agent: AVTECH/1.0\r\n"
Auth = "Authorization: Basic "+target_auth+"\r\n"

finalMessage = message + contentLength + contentType + Auth + "\r\n"
finalMessage = finalMessage + parameters
finalMessage = binascii.a2b_qp(finalMessage)
 
# connect the client 
client.connect((target_host,target_port))  
 
client.sendall(finalMessage);
 
# receive some data 
response = client.recv(131072)  
http_response = response
http_response_len = len(http_response)
 
#display the response
print("[RECV] - length: %d" % http_response_len)
print(http_response)

while True:
        try:
            sleep(1)
            # this is the problem here
            reply = client.recv(131072)
            if not reply:
	        print "Not prely, exit"
                break
            print "recvd: ", reply
        except KeyboardInterrupt:
            print "bye"
            break
client.close()
