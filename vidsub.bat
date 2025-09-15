@echo off
setlocal

if "%~1"=="" (
    echo Please drag and drop a video file onto this script.
    pause
    exit /b
)

:: === INPUT / OUTPUT SETUP ===
set "input=%~1"
set "filename=%~n1"
set "scriptdir=%~dp0"
set "outdir=%~dp1%filename%"

if not exist "%outdir%" mkdir "%outdir%"

set "audiofile=%outdir%\%filename%_AUDIO.mp3"
set "videofile=%outdir%\%filename%_VIDEO.mp4"
set "srtfile=%outdir%\%filename%_AUDIO.srt"
set "translated=%outdir%\%filename%_english.srt"


:: === STEP 1: Extract audio ===
echo Extracting audio...
"%scriptdir%ffmpeg.exe" -y -i "%input%" -vn -acodec libmp3lame "%audiofile%"
:: Extract video only
"%scriptdir%ffmpeg.exe" -i "%input%" -c copy -an "%videofile%"

:: === STEP 2: Check for subtitle streams ===
echo Checking for subtitles...
"%scriptdir%ffmpeg.exe" -i "%input%" 2>&1 | findstr "Subtitle:" >nul
if %errorlevel%==0 (
    echo Subtitles found, extracting...
    "%scriptdir%ffmpeg.exe" -y -i "%input%" -map 0:s:0 "%srtfile%"
) else (
    echo No subtitles found, generating with Whisper...
    python -m whisper "%audiofile%" --model medium --device cpu --output_format srt --output_dir "%outdir%"
    if exist "%outdir%\%filename%.srt" ren "%outdir%\%filename%.srt" "%filename%_original.srt"
)

REM :: === STEP 3: Translate subtitles ===
echo Translating subtitles to English...
set "pytemp=%outdir%\_translate_temp.py"

:: Write Python script with proper indentation
echo from deep_translator import GoogleTranslator>> "%pytemp%"
echo import os, time, sys>> "%pytemp%"
echo.>> "%pytemp%"
echo infile = r"%srtfile%">> "%pytemp%"
echo outfile = r"%translated%">> "%pytemp%"
echo.>> "%pytemp%"
echo def safe_translate(text, retries=3, delay=2):>> "%pytemp%"
echo     for attempt in range(retries):>> "%pytemp%"
echo         try:>> "%pytemp%"
echo             return GoogleTranslator(source="auto", target="en").translate(text)>> "%pytemp%"
echo         except Exception as e:>> "%pytemp%"
echo             time.sleep(delay)>> "%pytemp%"
echo     sys.stderr.write(f"[Warning] Failed to translate: {text}\n")>> "%pytemp%"
echo     return text>> "%pytemp%"
echo.>> "%pytemp%"
echo if os.path.exists(infile):>> "%pytemp%"
echo     with open(infile, "r", encoding="utf-8") as f:>> "%pytemp%"
echo         lines = f.readlines()>> "%pytemp%"
echo     out = []>> "%pytemp%"
echo     for line in lines:>> "%pytemp%"
echo         if line.strip() and not line.strip().isdigit() and "-->" not in line:>> "%pytemp%"
echo             out.append(safe_translate(line.strip()) + "\n")>> "%pytemp%"
echo         else:>> "%pytemp%"
echo             out.append(line)>> "%pytemp%"
echo     with open(outfile, "w", encoding="utf-8") as f:>> "%pytemp%"
echo         f.writelines(out)>> "%pytemp%"

cd "%outdir%
python "%pytemp%"

:: === STEP 4: Mux with 2 subtitle tracks ===
echo Muxing into final MP4 with subs...
"%scriptdir%ffmpeg.exe" -y -i "%input%" -i "%srtfile%" -i "%translated%" ^
   -map 0 -map 1 -map 2 -c copy -c:s mov_text ^
   -metadata:s:s:0 language=orig ^
   -metadata:s:s:1 language=eng ^
   "%finalout%"

echo.
echo Done! Files in: "%outdir%"
echo - %audiofile%
echo - %audiofile%
echo - %srtfile%
echo - %translated%

pause
