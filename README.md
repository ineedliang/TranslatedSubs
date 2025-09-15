Pre-Reqs

FFMPEG:: https://www.gyan.dev/ffmpeg/builds/ Get the "Full" version. Direct download from here - https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-full.7z

PYTHON 3.13:: https://www.python.org/downloads/ or direct download from here - https://www.python.org/ftp/python/3.13.7/python-3.13.7-amd64.exe

7Zip to extract the ffmpeg.7z - Direct link.. Dont click anything just wait for countdown. https://sourceforge.net/projects/sevenzip/files/latest/download

1) Install python and make sure to allow python to add to PATH in the beginning of the installer.
2) Create your working folder and extract ffmpeg into that folder.
3) Add This Batch file to the same folder as FFMPEG.EXE
4) Drag any video file right onto the vidsub.bat


How it works 
1) Batch uses ffmpeg to split out audio/video files
2) Creates a new folder inside your working folder with the name of the video file. ie.. if your file name is test.mp4, it will create a folder named test inside your working folder.
3) The split video and audio file will be placed into the new folder.
4) Batch file will attempt to install tool for python Called Whisper if it has not been previously installed
5) Whisper is a Transcriber that makes SRT files - Will listen to the speech in the audio file and create a SRT file
6) The batch program will then create a python script that will translate your srt file to english.


Final output: example using file named test.mp4
_Translate_temp.py - The python script created
test_audio.mp3 - The separated audio track in mp3 format
test_audio.srt - The original language srt subtitle file
test_english.srt - the converted to english subtitle file
test_video.mp4 - The video with no audio

I left all these in the folder to make sure the user knows that it was successful. You can now grab your original file and add the subtitle track (english) and should be good to go..
Right now this takes a bit of time because I set it up to use your cpu instead of your video card. The faster version only works if you have an Nvidia video card. I will be working 
on that version next. 

~Charliefromboston AKA Ineedliang
