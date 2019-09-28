import socket
import binascii
from time import sleep

target_host = "DVR.url" 
target_port = 80  
target_auth= "eqqjgGFJGJGJ323dq3=="

# create a socket object 
client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)  

message = "POST /cgi-bin/guest/SmartMonitor.cgi HTTP/1.1\r\n"
parameters = "userName=Ganesh&password=pass\r\n"
contentLength = "Content-Length: " + str(len(parameters))
contentType = "Content-Type: application/x-www-form-urlencoded\r\n"
Auth = "Authorization: Basic " + target_auth + "\r\n"

finalMessage = message + contentLength + contentType + Auth + "\r\n"
finalMessage = finalMessage + parameters
finalMessage = binascii.a2b_qp(finalMessage)
 
# connect the client 
client.connect((target_host,target_port))  
 
# send some data 
request = "GET /cgi-bin/guest/SmartMonitor.cgi HTTP/1.1\r\nHost:%s\r\n"+Auth+"\r\n" % target_host
#client.send(request.encode())  
client.sendall(finalMessage);
 
# receive some data 
response = client.recv(4096)  
http_response = repr(response)
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
                break
            print "recvd: ", reply
        except KeyboardInterrupt:
            print "bye"
            break
client.close()

#0
#OK
#SmartMonitor=Alive                                                                                                                            Channel=0x2                                                                                                                


#0
#OK
#SmartMonitor=Start                                                                                                                            Channel=0x2                                                                                                                                   Time=2019/09/28 17:25:22
#Channel=0x2
#Time=2019/09/28 17:25:22
