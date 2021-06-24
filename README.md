# x86-Assembly-Video-To-Ascii
Convert video frames into ASCII images and display them like a video.  
- [Slides](https://docs.google.com/presentation/d/e/2PACX-1vRznOLbSu8_zhEzIncXldoHirTjhf4AbNGenwztffDnNYiq7Bd_RviMGZZ10Xcf0u1ewcefoPequ0Ym/pub?start=false&loop=false&delayms=60000)
- [Demo Video](https://youtu.be/tX2rsnZPxAA)

# Set up a development environment
## Untrack These Files in Git  
The project must be open with these files, but you can untrack them if you don't want to commit them to git.  
`git update-index --assume-unchanged .\.vs\Video2Acsii\v16\.suo`  
`git update-index --assume-unchanged .\.vs\Video2Acsii\v16\Browse.VC.db`

## Get Started with MASM and Visual Studio
Follow the instructions from the website of the library [here](http://asmirvine.com/gettingStartedVS2019/index.htm).

## Add Assets to The Project  
#### Video Frames
1. Create a folder named `frames` in the project root directory.
2. Put all the video frames image files (`BMP` file format) into `./frames`.
3. These images should be named with their index (From `0000.bmp` to `9999.bmp`)  

**[Important!]** The width of the images must be a multiple of 4. (`64*40` is recommended for resolution of the images.)
#### Audios
1. Create a folder named `audios` in the project root directory.
2. Put the background music WAV file into `./audios` and name with `bgm.wav`.

## Set Total Frames Number in The Source Code.  
1. Change the value of `totalFrames` in line [62](https://github.com/JiaxuanTW/x86-Assembly-Video-To-Ascii/blob/1fd690df0697c485040435b67f972438c9ef62b9/Source.asm#L62) of `Source.asm`
