#h265
ffmpeg -i video.dv4  -vf "split [maint][mainb];[maint]crop=iw:ih/2:0:0[ftop];[mainb]crop=iw:ih/2:0:ih/2[fbot];[ftop]scale=iw:ih[f1];[fbot]scale=iw:ih[f2];[f1][f2]framepack=lines,yadif" -c:v libx265  out-265.mp4

#h264
ffmpeg -i video.dv4  -vf "split [maint][mainb];[maint]crop=iw:ih/2:0:0[ftop];[mainb]crop=iw:ih/2:0:ih/2[fbot];ftop]scale=iw:ih[f1];[fbot]scale=iw:ih[f2];[f1][f2]framepack=lines,yadif"  -c:v libx264 out-264.mp4


#https://lexxai.blogspot.com/2019/09/split-united-interlaced-video-to-frames.html
