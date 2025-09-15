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
set "finalout=%outdir%\%filename%_final.mp4"

:: === STEP 0a: Ensure PyTorch installed ===
echo Checking for PyTorch...
python -c "import torch" 2>nul
IF %ERRORLEVEL% NEQ 0 (
    echo [INFO] PyTorch not found. Installing now...
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
) ELSE (
    echo [INFO] PyTorch already installed.
)

:: === STEP 0b: Ensure Whisper installed ===
echo Checking for Whisper...
python -c "import whisper" 2>nul
IF %ERRORLEVEL% NEQ 0 (
    echo [INFO] Whisper not found. Installing now...
    pip install -U openai-whisper
) ELSE (
    echo [INFO] Whisper already installed.
)

:: === STEP 0c: Ensure deep-translator installed ===
echo Checking for deep-translator...
python -c "import deep_translator" 2>nul
IF %ERRORLEVEL% NEQ 0 (
    echo [INFO] deep-translator not found. Installing now...
    pip install -U deep-translator
) ELSE (
    echo [INFO] deep-translator already installed.
)

:: === STEP 1: Extract audio ===
echo Extracting audio...
"%scriptdir%ffmpeg.exe" -y -i "%input%" -vn -acodec libmp3lame "%audiofile%"
:: Extract video only
"%scriptdir%ffmpeg.exe" -i "%input%" -c copy -an "%videofile%"

:: === STEP 2: Subtitles ===
echo Checking for subtitles...
"%scriptdir%ffmpeg.exe" -i "%input%" 2>&1 | findstr "Subtitle:" >nul
if %errorlevel%==0 (
    echo Subtitles found, extracting...
    "%scriptdir%ffmpeg.exe" -y -i "%input%" -map 0:s:0 "%srtfile%"
) else (
    echo No subtitles found, generating with Whisper...
    :: Detect if CUDA is available
    python -c "import torch; exit(0) if torch.cuda.is_available() else exit(1)"
    if %ERRORLEVEL%==0 (
        echo [INFO] CUDA available, using GPU
        python -m whisper "%audiofile%" --model large --device cuda --output_format srt --output_dir "%outdir%"
    ) else (
        echo [INFO] CUDA not available, using CPU
        python -m whisper "%audiofile%" --model medium --device cpu --output_format srt --output_dir "%outdir%"
    )
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

"%scriptdir%ffmpeg.exe" -y -i "%videofile%" -i "%audiofile%" -i "%srtfile%" -i "%translated%" -map 0:v -map 1:a -map 2 -map 3 -c:v copy -c:a copy -c:s mov_text -metadata:s:s:0 language=orig -metadata:s:s:1 language=eng "%outdir%\%filename%_final.mp4"

echo.
echo Done! Files in: "%outdir%"
echo - %audiofile%
echo - %videofile%
echo - %srtfile%
echo - %translated%
echo - %finalout%
pause
