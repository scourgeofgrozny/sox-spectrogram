@echo off & title %~nx0 & color 5F & chcp 65001 >NUL
rem Based on this thread here: https://stackoverflow.com/a/13351373
rem RED thread here: https://redacted.ch/forums.php?action=viewthread&threadid=2772&postid=395984#post395984
goto :BEGIN_SPECTROGRAM
:CMD_SIZE
chcp 850 >NUL & set "uiWidth=%1" & set "uiHeight=%2"
mode %uiWidth%,%uiHeight%
if %4==TRUE (set /a "uiHeightBuffer=uiHeight+%3")
if %4==TRUE (powershell.exe -ExecutionPolicy Bypass -Command "&{$H=get-host;$W=$H.ui.rawui;$B=$W.buffersize;$B.width=%uiWidth%;$B.height=%uiHeightBuffer%;$W.buffersize=$B}")
if %4==FALSE (powershell.exe -ExecutionPolicy Bypass -Command "&{$H=get-host;$W=$H.ui.rawui;$B=$W.buffersize;$B.width=%uiWidth%;$B.height=%uiHeight%;$W.buffersize=$B}")
chcp 65001 >NUL & goto :EOF

set vernumber=1.7
::::::::::::::::::::::::::::::::::::::::::::::::
:: HISTORY OF CHANGES
:: 2020.03.21 - v1.7  - New option that opens folder once that folder has been processed, if the folder is already open, windows will send focus to it instead.
:: 2020.03.06 - v1.6  - Fixed some bugs n' stuff and added new resize UI method  thus removing old method.
:: 07.08.2018 - v1.5  - Added full automation via a 10 second timer to the preserve PICTURE question. Defaulted to YES. Timer was in the Spectrograms before.
::                      Fixed small bug in PRE_RUN_WITH_DEFAULTS_AFTER_TIMEOUT section.
:: 17.07.2018 - v1.4  - Added .aiff support.
::                    - Minor tweaks.
::                    - Added resizing of the UI with a seperate .bat file. (see https://stackoverflow.com/a/13351373 for how this works)
::                           - Just place this code minus the :: at the start of each line and save to any location as 'Spectrograms_UI_Size.bat'.
::                           - Then is the code below, where it says set 'SPECTROGRAMS_UI_SIZE_FILE', change the direct path to your 'Spectrograms_UI_Size.bat' file.
::
::                                @echo off
::                                mode con:cols=15 lines=1
::                                color 5F
::                                :Spectrograms_UI_Size winWidth winHeight bufWidth bufHeight
::                                mode con: cols=%1 lines=%2
::                                powershell -command "&{$H=get-host;$W=$H.ui.rawui;$B=$W.buffersize;$B.width=%3;$B.height=%4;$W.buffersize=$B;}"
::
::                           - Then change the size of the cmd by changing this line.
::                                call Spectrograms_UI_Size 170 55 170 9999.
::
::                           - The syntax for this code is: cmdcall call winWidth winHeight bufWidth bufHeight.
::                           - It is important that the window size is always less than or equal to the buffer size.
::
:: 12.04.2018 - v1.3  - Added timeout on run. Will run with defaults after X amount of seconds shown.
::
:: 25.03.2018 - v1.2  - Added option for dB range (SoX -z argument). ENTER on keyboard defaults to displayed value at prompt.
::                    - Added option for [M:SS] (SoX -S argument) for zoomed plots. ENTER on keyboard defaults to displayed value at prompt.
::                    - Added option to delete files based on their filename inside the SOX_FOLDER_NAME folder. ENTER on keyboard defaults to 'No'.
::                    - Tweaked the output, AGAIN. Now displays the folders before the files.
::                    - .png filenames are now:
::                           - For full plots:   'filename+ext-VALdB-FULL.png' e.g. '1 - Worakls - Question reponse.flac-120dB-FULL.png'
::                           - For zoomed plots: 'filename+ext-VALdB-1.00[M.SS]-ZOOM.png' e.g. '1 - Worakls - Question reponse.flac-120dB-1.00[M.SS]-ZOOM.png'
::
:: 18.03.2018 - v1.1  - Added recursive folder scanning.
::                    - Rewrote the folder fn.
::                    - Some bug fixes & cleaned up CMD output.
::                    - Added skippage of existing output .png files. It'll ignore all previously done exports providing that you haven't moved stuff around or renamed the filenames.
::
:: 11.03.2018 - v1.0  - Created by Stiffler147 for The "Is this a transcode?" thread on RED.
::
::::::::::::::::::::::::::::::::::::::::::::::::
:: dB VALUE NOTES FROM DeepseaTorpedo
:: For standard Red Book CDs 16/44.1 files 120 is OK, most files will show all the energy levels available,
:: and only very few cases would need 130. Using 130 for all might result in "blocky" look-like harmonics.
:: For 24/xxx files we need to increase it to 140dB, but very well recorded stuff could need 150dB to show
:: the very low level energy which could get lost in smaller ranges and looking as if there were a lowpass filter.
::::::::::::::::::::::::::::::::::::::::::::::::
:: SoX LINKS
:: Download your updates here: https://www.videohelp.com/software/SoX
:: It has a few dependencies such as libmad.dll for mp3's which should be placed in the same root folder as where SoX is installed. Found at the same link above.
::::::::::::::::::::::::::::::::::::::::::::::::

:BEGIN_SPECTROGRAM
call :CMD_SIZE 140 44 222 TRUE
set SOX_FOLDER_NAME=Spectrograms
set SOX_EXE=""
if not exist %SOX_EXE% goto MSG_ERROR_SOX_EXE_NOT_FOUND
: Define the full path to the file "metaflac.exe". Choose the win32 or win64 version depending on your OS.
set METAFLAC_EXE=""
if not exist %METAFLAC_EXE% goto MSG_ERROR_METAFLAC_EXE_NOT_FOUND

title Batch Spectrograms to the '%SOX_FOLDER_NAME%' folder.          '

echo/--------------------------------------------
echo|set /p="SoX.exe path + version: " >> temp_SoX_Ver.txt
%SOX_EXE% --version >> temp_SoX_Ver.txt && type temp_SoX_Ver.txt
del "temp_SoX_Ver.txt"

echo/--------------------------------------------
echo Version %vernumber% of ' %~nx0 '
echo/--------------------------------------------
echo/README
echo/--------------------------------------------
echo/ - If the '%SOX_FOLDER_NAME%' folder does not exist, it'll create it in their respective folders.
echo/ - It will skip any previously exported plots as long as no filenames or settings have changed.
echo/ - Delete option will delete using the mask 'filename*.png'. ENTER on keyboard here defaults to 'No'.
echo/ - -z switch option: dB level is set to '130' as default. ENTER on keyboard to use default value.
echo/ - -S switch option: Controls the time in [M:SS] for zoomed plots. '1:00' is default. ENTER on keyboard to use default value.
echo/ - For a full overview of ' %~nx0 ', open it in Notepad++/Sublime Text for best viewing and read the header.
echo/--------------------------------------------
echo/OPTIONS
echo/--------------------------------------------
echo/

:OPEN_DIRECTORY
choice /M "[Opt 1 of 2]  Do you want to open the directory after each has finished [Yes/No] ~ 10 SECOND TIMER ~ " /T 10 /D Y
if errorlevel 255 (
  echo/ Error
  ) else if errorlevel 2 (
  set "OPEN_DIRECTORY_ANS=WILL NOT"
  goto PICTURE
  ) else if errorlevel 1 (
  set "OPEN_DIRECTORY_ANS=WILL"
  goto PICTURE
  ) else if errorlevel 0 (
  goto: PICTURE
  )

  :PICTURE
  echo/^> Folders, %OPEN_DIRECTORY_ANS% be opened after each has been processed.
  echo/
  echo/--------------------------------------------
  echo/
  choice /M "[Opt 2 of 2]  Do you want to preserve the files PICTURE [Yes/No] ~ 10 SECOND TIMER ~ " /T 10 /D Y
  if errorlevel 255 (
    echo/ Error
    ) else if errorlevel 2 (
    set "PICTURE_ANS=WILL NOT"
    goto PRE_RUN_WITH_DEFAULTS_AFTER_TIMEOUT
    ) else if errorlevel 1 (
    set "PICTURE_ANS=WILL"
    goto PRE_RUN_WITH_DEFAULTS_AFTER_TIMEOUT
    ) else if errorlevel 0 (
    goto: PRE_RUN_WITH_DEFAULTS_AFTER_TIMEOUT
    )

    :PRE_RUN_WITH_DEFAULTS_AFTER_TIMEOUT
    echo/^> Files PICTURE, %PICTURE_ANS% be preserved.
    echo/
    echo/--------------------------------------------
    echo/
    CHOICE /m "[Load Spectrograms Defaults] Load Defaults? [Yes/No] ~ 10 SECOND TIMER ~ " /T 10 /D Y
    if errorlevel 255 (
      echo/ Error
      ) else if errorlevel 2 (
      goto DELETE_FIRST_STEP
      ) else if errorlevel 1 (
      goto RUN_WITH_DEFAULTS_AFTER_TIMEOUT
      ) else if errorlevel 0 (
      goto: DELETE_FIRST_STEP
      )

      :RUN_WITH_DEFAULTS_AFTER_TIMEOUT
      echo/
      echo/Running with the following defaults:
      echo/
      set "DELETE_FILES_ANS=No"
      set "DELETE_REPLY=WILL NOT"
      echo/^> Previously exported .png plot files %DELETE_REPLY% be deleted.
      set "SECONDS_VAL_DEFAULT=1:00"
      set "SECONDS_VAL_INPUT=%SECONDS_VAL_DEFAULT%"
      echo/^> Minute mark set to %SECONDS_VAL_DEFAULT%.
      set "DB_VAL_DEFAULT=120"
      set "DB_VAL_INPUT=%DB_VAL_DEFAULT%"
      echo/^> dB value set to %DB_VAL_DEFAULT%.
      echo/
      goto START_MAIN_ROUTINE

      :DELETE_FIRST_STEP
      echo/
      set "DELETE_FILES_ANS=No"

      :DELETE_STEP
      choice /M "[Opt 1 of 3] Do you want to delete old exported .pngs"

      if errorlevel 255 (
        echo Error
        ) else if errorlevel 2 (
        set "DELETE_REPLY=WILL NOT"
        set "DELETE_FILES_ANS=No"
        goto DB_USER_INPUT
        ) else if errorlevel 1 (
        set "DELETE_REPLY=WILL"
        set "DELETE_FILES_ANS=Yes"
        goto DB_USER_INPUT
        ) else if errorlevel 0 (
        goto DB_USER_INPUT
        )

:: Some help got here: https://stackoverflow.com/questions/684301/batch-file-input-validation-make-sure-user-entered-an-integer
:: Cannot use the pipe | in reg exp as it's not supported in CMD so cannot match 120-150. So I've opted for 120-159 as the choice.
:DB_USER_INPUT
echo/^> Previously exported .png plot files %DELETE_REPLY% be deleted.
echo/
set "DB_VAL_DEFAULT=120"
set /p "DB_VAL_INPUT=[Opt 2 of 3] Enter a range between 120-159dB or press [ENTER] for default [%DB_VAL_DEFAULT%dB]: "
if not defined DB_VAL_INPUT (
  set "DB_VAL_INPUT=%DB_VAL_DEFAULT%"
  echo/^> dB value set to %DB_VAL_DEFAULT%.
  echo/
  goto SECONDS_USER_INPUT
  )
echo %DB_VAL_INPUT%|findstr /r /c:"^[1][2-5][0-9]$" >nul
if errorlevel 1 (goto DB_USER_INPUT) else (
  echo/^> dB value set to %DB_VAL_INPUT%.
  echo/
  goto SECONDS_USER_INPUT
  )

:SECONDS_USER_INPUT
set "SECONDS_VAL_DEFAULT=1:00"
set /p "SECONDS_VAL_INPUT=[Opt 3 of 3] Minute mark of zoomed in plot in [M:SS]. Press [ENTER] for default [%SECONDS_VAL_DEFAULT%]: "
if not defined SECONDS_VAL_INPUT (
  set "SECONDS_VAL_INPUT=%SECONDS_VAL_DEFAULT%"
  echo/^> Minute mark set to %SECONDS_VAL_DEFAULT%.
  goto START_MAIN_ROUTINE
  )
echo %SECONDS_VAL_INPUT%|findstr /r /c:"^[0-5]:[0-9][0-9]$" >nul
if errorlevel 1 (goto SECONDS_USER_INPUT) else (
  echo/^> Minute mark set to %SECONDS_VAL_INPUT%.
  goto START_MAIN_ROUTINE
  )

:START_MAIN_ROUTINE
Setlocal EnableDelayedExpansion
set SECONDS_VAL_NAME=%SECONDS_VAL_INPUT%
set SECONDS_VAL_NAME=!SECONDS_VAL_NAME::=.![M.SS]

echo/--------------------------------------------
echo/
echo PLEASE WAIT %username%, outputting spectrograms from dropped folder/s AND/OR file/s ^<:]
echo/
echo/--------------------------------------------

for %%I IN (%*) DO (

  echo/%%~aI | find "d" >NUL

  if errorlevel 1 (
:: Process Dropped Files
echo/

cd /d %%~dpI

echo/^> FILE ' %%~nI%%~xI '

for /f "tokens=*" %%I in ('DIR /B/OGDN "%%~nI.flac" "%%~nI.aiff" "%%~nI.mp3" "%%~nI.acc" 2^>NUL') DO (

  if not exist %SOX_FOLDER_NAME%\NUL (
    MKDIR %SOX_FOLDER_NAME%
    )
:: Option to delete all previously exported plots in the Spectrograms folder.
if /i not "%DELETE_FILES_ANS:Yes=%"=="%DELETE_FILES_ANS%" (if exist "%%~dpI%SOX_FOLDER_NAME%\%%~nxI-*.png" echo    ^> DELETING SPECTROGRAM: ' %%~nxI '
  del "%%~dpI%SOX_FOLDER_NAME%\%%~nxI-*.png")

for /f "tokens=*" %%I in ('DIR /B/OGDN "%%~nI.flac" 2^>NUL') DO (
:: Remove Padding
if "%PICTURE_ANS%"=="WILL NOT" (
  echo    ^> REMOVING PICTURE: ' %%~nxI '
  %METAFLAC_EXE% --preserve-modtime --dont-use-padding --remove --block-type=PADDING,PICTURE "%%~I"
  %METAFLAC_EXE% --preserve-modtime --add-padding=8192 "%%~I"
  )
)

:: Full Plot
if exist "%%~dpI%SOX_FOLDER_NAME%\%%~nxI-%DB_VAL_INPUT%dB-FULL.png" (
  echo    ^> ALREADY EXPORTED: ' %%~nxI-%DB_VAL_INPUT%dB-FULL.png '
  )
if not exist "%%~dpI%SOX_FOLDER_NAME%\%%~nxI-%DB_VAL_INPUT%dB-FULL.png" (
  %SOX_EXE% "%%~I" -n remix 1 spectrogram -x 3000 -y 513 -z %DB_VAL_INPUT% -w Kaiser -o "%SOX_FOLDER_NAME%\%%~nxI-%DB_VAL_INPUT%dB-FULL.png"
  echo    ^> EXPORTED: ' %%~nxI-%DB_VAL_INPUT%dB-FULL.png '
  )

:: Zoomed Plot
if exist "%%~dpI%SOX_FOLDER_NAME%\%%~nxI-%DB_VAL_INPUT%dB-ZOOM-%SECONDS_VAL_NAME%.png" (
  echo    ^> ALREADY EXPORTED: ' %%~nxI-%DB_VAL_INPUT%dB-ZOOM-%SECONDS_VAL_NAME%.png '
  )
if not exist "%%~dpI%SOX_FOLDER_NAME%\%%~nxI-%DB_VAL_INPUT%dB-ZOOM-%SECONDS_VAL_NAME%.png" (
  %SOX_EXE% "%%~I" -n remix 1 spectrogram -X 500 -y 1025 -z %DB_VAL_INPUT% -w Kaiser -S %SECONDS_VAL_INPUT% -d 0:02 -o "%SOX_FOLDER_NAME%\%%~nxI-%DB_VAL_INPUT%dB-ZOOM-%SECONDS_VAL_NAME%.png"
  echo    ^> EXPORTED: ' %%~nxI-%DB_VAL_INPUT%dB-ZOOM-%SECONDS_VAL_NAME%.png '
  )

)

) else (

cd /d %%I

echo/
echo/^> DIRECTORY [ %%I ]

for /r %%I in (*.flac, *.mp3, *.aiff, *.acc) do (

  cd /d %%~dpI

:: Option to delete all previously exported plots in the Spectrograms folder.
if /i not "%DELETE_FILES_ANS:Yes=%"=="%DELETE_FILES_ANS%" (if exist "%%~dpI%SOX_FOLDER_NAME%\%%~nxI-*.png" echo    ^> DELETING SPECTROGRAM: ' %%~nxI '
  del "%%~dpI%SOX_FOLDER_NAME%\%%~nxI-*.png")
:: Remove Padding
if "%%~xI"==".flac" (
  if "%PICTURE_ANS%"=="WILL NOT" (
    echo    ^> REMOVING PICTURE: ' %%~nxI '
    %METAFLAC_EXE% --preserve-modtime --dont-use-padding --remove --block-type=PADDING,PICTURE "%%~I"
    %METAFLAC_EXE% --preserve-modtime --add-padding=8192 "%%~I"
    )
  )
:: Full Plot
if exist "%%~dpI%SOX_FOLDER_NAME%\%%~nxI-%DB_VAL_INPUT%dB-FULL.png" (
  echo    ^> ALREADY EXPORTED: ' %%~nxI-%DB_VAL_INPUT%dB-FULL.png '
  )
if not exist "%%~dpI%SOX_FOLDER_NAME%\%%~nxI-%DB_VAL_INPUT%dB-FULL.png" (
  if not exist %SOX_FOLDER_NAME%\NUL MKDIR %SOX_FOLDER_NAME%
  %SOX_EXE% "%%I" -n remix 1 spectrogram -x 3000 -y 513 -z %DB_VAL_INPUT% -w Kaiser -o "%%~dpI%SOX_FOLDER_NAME%\%%~nxI-%DB_VAL_INPUT%dB-FULL.png"
  echo    ^> EXPORTED: ' %%~nxI-%DB_VAL_INPUT%dB-FULL.png '
  )
:: Zoomed Plot
if exist "%%~dpI%SOX_FOLDER_NAME%\%%~nxI-%DB_VAL_INPUT%dB-ZOOM-%SECONDS_VAL_NAME%.png" (
  echo    ^> ALREADY EXPORTED: ' %%~nxI-%DB_VAL_INPUT%dB-ZOOM-%SECONDS_VAL_NAME%.png '
  )
if not exist "%%~dpI%SOX_FOLDER_NAME%\%%~nxI-%DB_VAL_INPUT%dB-ZOOM-%SECONDS_VAL_NAME%.png" (
  if not exist %SOX_FOLDER_NAME%\NUL MKDIR %SOX_FOLDER_NAME%
  %SOX_EXE% "%%I" -n remix 1 spectrogram -X 500 -y 1025 -z %DB_VAL_INPUT% -w Kaiser -S %SECONDS_VAL_INPUT% -d 0:02 -o "%%~dpI%SOX_FOLDER_NAME%\%%~nxI-%DB_VAL_INPUT%dB-ZOOM-%SECONDS_VAL_NAME%.png"
  echo    ^> EXPORTED: ' %%~nxI-%DB_VAL_INPUT%dB-ZOOM-%SECONDS_VAL_NAME%.png '
  )
)
:: Open Directory
if "%OPEN_DIRECTORY_ANS%"=="WILL" (
  %SystemRoot%\explorer.exe "%%~I"
  )
)
)

:PROCESS_COMPLETE
echo/ & echo/-------------------------------------------- & color 0E & echo/
title   PROCESS COMPLETE... & echo   PROCESS COMPLETE...
echo/ & echo/--------------------------------------------
set /p "=" <NUL
ping localhost -n 20 >NUL & exit
rem @pause
EXIT

:MSG_ERROR_SOX_EXE_NOT_FOUND
echo/ & echo/-------------------------------------------- & color 0E & echo/
title    Path to 'sox.exe' unresolved... & echo    Path to 'sox.exe' unresolved...
echo/ & echo    Process stopped. Open [%~nx0] and correct the path.
set /p "=" <NUL
ping localhost -n 10 >NUL & exit
rem @pause
EXIT

:MSG_ERROR_METAFLAC_EXE_NOT_FOUND
echo/ & echo/-------------------------------------------- & color 0E & echo/
title    Path to 'metaflac.exe' unresolved... & echo    Path to 'metaflac.exe' unresolved...
echo/
echo    Process stopped. Open [%~nx0] and correct the path.
set /p "=" <NUL
ping localhost -n 10 >NUL & exit
rem @pause
EXIT
