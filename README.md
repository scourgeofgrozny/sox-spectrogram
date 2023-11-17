# sox-spectrogram
Batch script that makes spectral analysis simple and straightforward using SoX. Consider checking out the main 
[documentation](https://sox.sourceforge.net/sox.html) if you haven't already. 

## Requirements
[flac/metaflac](https://xiph.org/flac/download.html) and [SoX](https://sourceforge.net/projects/sox/)

### Instructions
- Open spectrograms.bat in notepad++ or any application that supports batchfile editing
- Edit the path in lines 71 and 74 (```set SOX_EXE=""``` and ```set METAFLAC_EXE```) to point to the path of these executables.
- Edit the output directory name if you wish in line 70.

### Functions/Features
- Supports dragging & dropping of folders and files at the same time.
- Drag folders and files at the same time to the .bat file and it'll output the FULL and ZOOMED plots of the files.
- It will create a folder called Spectrograms in the same folder as the folders and for the file it'll also create a folder with the same name in that directory.
- Auto-closes after 10 seconds after exporting spectrograms.
