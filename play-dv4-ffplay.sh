ffplay -i video.dv4  -vf "split [maint][mainb];[maint] crop=iw:ih/2:0:0 [ftop];[mainb] crop=iw:ih/2:0:ih/2 [fbot]; [ftop]scale=iw:ih[f1]; [fbot]scale=iw:ih[f2]; [f1][f2]framepack=lines,yadif" 
