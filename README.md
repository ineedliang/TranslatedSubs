Pre-Reqs

FFMPEG:: https://www.gyan.dev/ffmpeg/builds/ Get the "Full" version. or you can download directly from this link
https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-full.7z

PYTHON 3.13:: https://www.python.org/downloads/ or direct download from this link
https://www.python.org/ftp/python/3.13.7/python-3.13.7-amd64.exe

7Zip to extract the ffmpeg.7z - Direct link.. Dont click anything just wait for countdown. 
https://sourceforge.net/projects/sevenzip/files/latest/download


1) Install python and make sure to allow  "add to PATH" in the beginning of the installer.
2) Create your working folder and extract ffmpeg into that folder.
3) Add This Batch file to the same folder as FFMPEG.EXE
4) Drag any video file right onto the vidsub.bat


How it works 
1) Batch uses ffmpeg to split out audio/video files
2) Creates a new folder inside your working folder with the name of the video file. ie.. if your file name is test.mp4, it will create a folder named test inside your working folder.
3) The split video and audio file will be placed into the new folder.
4) Batch file will attempt to install tool for python Called Whisper if it has not been previously installed 
        (Whisper OpenAI's Whisper is a powerful automatic speech recognition (ASR) model that can be used with Python to transcribe audio into SRT file in combinaton with Deep Translate)
5) Batch file will attempt to install tool for python Called Deep-Translate if it has not been previously installed
        (Deep Translate - translate between different languages in a simple way using multiple translators.)
6) Batch file will attempt to install tool for python Called Pytorch if is has not been previously installed
        an open-source machine learning library based on the Torch library accelerating processes using cuda cores from Nvidia video card
7) The batch program will then create a python script that will translate your srt file to english.
8) If pytorch fails, batch file will fall back to using cpu which is of course alot slower but still works.


Final output: example using file named test.mp4

_Translate_temp.py - The python script created

test_audio.mp3 - The separated audio track in mp3 format

test_audio.srt - The original language srt subtitle file

test_english.srt - the converted to english subtitle file

test_video.mp4 - The video with no audio

test_final.mp4 - Puts the video back together


I left all these in the folder to make sure the user knows that it was successful. 
You can now grab your original file and add the subtitle track (english) and should be good to go.. 

Note: There might be some sort of tweaking or replacement of pytorch that might work better on your system however pytorch is known to have so many revisions that chances of accelerating the process on your system is slim to none without tweaking heavily..

~Charliefromboston AKA Ineedliang  -- Inspired by 2busy2Sleep
