Put the latest compiled version of ffmpeg into a folder with this batch file. 
Install python 3.13 64 bit and make sure you check the box to add path.

Drag any video file into the batch file 
Batch uses ffmpeg to split out audio and video and places them into a folder of the same name as your file.

on your first try the batch file will install whisper - this dictates the speech to SRT file
if whisper doesnt see a srt file in that folder, it will create an srt file 
batch then creates a python script that will translate your srt file to english

Final output: English SRT, Original Language SRT, Video (mp4) with no audio and audio file (mp3) 
Will update when I have it put all back together with new Video with srt embedded into it..
