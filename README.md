# sox-spectrogram
Batch script that makes spectral analysis simple and straightforward using SoX. Consider checking out the main 
[documentation](https://sox.sourceforge.net/sox.html) if you haven't already. 

### Instructions
- Open spectrograms.bat in notepad++ or any application that supports batchfile editing
- Edit the path in the line ```SET SOX_EXE="W:\Apps (Portable)\Music Apps\SoX\sox.exe"``` to point to the path of your sox.exe.
- Edit the name if you wish in the line ```set SOX_FOLDER_NAME=_Spectrograms```

### Functions/Features
- Supports dragging & dropping of folders and files at the same time.
- Just drag folders and files at the same time to the .bat file and it'll output the FULL and ZOOMED plots of the files.
- It will create a folder called _Spectrograms in the same folder as the folders and for the files, it'll create a folder with the same name in that directory also.
- Auto closes after 10 seconds after exporting Spectrograms.
