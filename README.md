dosdir2lpl v0.5 - Generate RetroArch playlists from an unzipped DOS files directory scan.

with dosdir2lpl [directory ...]
Notes:
  this calculates the crc32 values of each (.bat, .exe, .com) and these are added to the playlist  priority goes to batch files (skipping other executables) in each directory
  if batch files are not found the executables will be added to the playlist

  [directory] should be the path to the games folder, each game will be named after game subfolders
              the command line must contain backslash symbols

Example:
              dosdir2lpl "D:/ROMS/DOS"

Author:
   Discord - Romeo#3620