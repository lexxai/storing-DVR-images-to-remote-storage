import socket
import binascii
from time import sleep

target_host = "DVR.url" 
target_port = 80  
target_auth = "eqqjgGFJGJGJ323dq3=="

# create a socket object 
client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)  
path = "./video.dv4" 

message = "POST /cgi-bin/supervisor/NetworkBk.cgi HTTP/1.1\r\nHost: %s:%d\r\n" % target_host target_port
message += "Connection: keep-alive\r\nAccept: */*\r\n"
parameters = "action=download&start_time=2019 09 23 00 03 27&end_time=2019 12 23 00 03 58&num=255&ch=1" 
contentLength = "Content-Length: " + str(len(parameters)) + "\r\n"
contentType = "Content-Type: application/x-www-form-urlencoded\r\nAccept-Language: en-us\r\n"
contentType +="User-Agent: Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322)\r\n"
Auth = "Authorization: Basic "+ target_auth +"\r\n"

finalMessage = message + contentLength + contentType + Auth + "\r\n"
finalMessage = finalMessage + parameters
#finalMessage = binascii.a2b_qp(finalMessage)
 
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
f=open(path, 'wb') 
while True:
        try:
            #sleep(1)
            # this is the problem here
            reply = client.recv(1310720000)
            if not reply:
	        print "Not prely, exit"
                break
            #print "recvd: ", reply
	    print ("recvd len %d") % len(reply)	
            f.write(reply)

        except KeyboardInterrupt:
            print "bye"
            break
client.close()
f.close()




