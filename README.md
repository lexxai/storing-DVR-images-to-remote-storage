# storing-DVR-images-to-remote-storage
 By small devices with OpenWRT can extend feature of old DVR devices. Used shell scripts for connect to AVtech DVR devices, detect motion state, get images and store to remote storage by webdav. Can add notification to Telegram.
 
Tested with:
 - DVR security device AVtech KPD 672 (Analog, MPEG-4)
 - OpenWRT 18.06 Device wifi router: TPlink 1043, RAM 64M
 - NextCloud cloud remote storage
 
Scripts:
Used /bin/sh shell enviromant and additional 
 - dvr-synctime.sh - Force Sync dvr for get time from NTP server
 - getImages-pull.sh - Get images by pereodically requests to motion table of DVR. Script runned by cron every 1 mins.
 - getImages-wait.sh - Get information about DVR state by connect to tcp socket of DVR and wait changes of state. Script run bt boot and always loaded.
 - getImg.sh - Get images (snapshot) from DVR sceen and save repeatly during some time to remote storage by use webdav protocol.
 - purge_old.sh - Remove old files from remote storage.
 

Python:
  	
   - getLiveState.py
   - getMotion-table.py
   - getVideo.py
   
Video format .dv4:
  
  -  play-dv4-ffplay.sh  - Play .dv4 media
  -  convert-dv4-ffmpeg.sh - Convert .dv4 media to .mp4


More information on blog:
- https://lexxai.blogspot.com/2019/09/dvr-nextcloud-webdav.html
- https://lexxai.blogspot.com/2019/09/split-united-interlaced-video-to-frames.html

