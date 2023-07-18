# FFmpeg cheat sheet

## Quick convert:

````
ffmpeg -i vid.mp4 vid.*(avi,mov,webm,mkv)
````

### Remux an MKV file into MP4:

````
ffmpeg -i vid.mkv -c:v copy -c:a copy vid.mp4
````

### High-quality encoding:
````
ffmpeg -i vid.mp4 -preset slower -crf 18 vid.mp4
````

## Cutting:

Without re-encoding:
````
ffmpeg -ss [start] -i vid.mp4 -t [duration] -c copy vid.mp4
````
With re-encoding:
````
ffmpeg -ss [start] -i vid.mp4 -t [duration] -c:v libx264 -c:a aac -strict experimental -b:a 128k vid.mp4
````

## Merging:

Make a .txt file with all of the video files in order like this:
````
file 'vid.mp4'
file 'vid2.mp4'
file 'vid3.mp4'
file 'vid4.mp4'
````
Then, run:
````
ffmpeg -f concat -i list.txt -c copy vid.mp4
````

## Extract the frames from a video

To extract all frames from between 1 and 6 seconds, and also between 11 and 13 seconds:

````
ffmpeg -i vid.mp4 -vf select='between(t,1,6)+between(t,11,13)' -vsync 0 out%d.png
````

To extract one frame per second only:

````
ffmpeg -i vid.mp4 -fps=1 -vsync 0 out%d.png
````

## Rotate a video

Rotate 90 clockwise:

````
ffmpeg -i vid.mov -vf "transpose=1" vid.mov
````

For the transpose parameter you can pass:

````
0 = 90CounterCLockwise and Vertical Flip (default)
1 = 90Clockwise
2 = 90CounterClockwise
3 = 90Clockwise and Vertical Flip
````

Use `-vf "transpose=2,transpose=2"` for 180 degrees.

## Create a video slideshow from images

Parameters: `-r` marks the image framerate (inverse time of each image); `-vf fps=25` marks the true framerate of the output.

````
ffmpeg -r 1/5 -i img%03d.png -c:v libx264 -vf fps=25 -pix_fmt yuv420p vid.mp4
````

## Extract images from a video

- Extract all frames: `ffmpeg -i vid.mp4 thumb%04d.jpg -hide_banner`
- Extract a frame each second: `ffmpeg -i vid.mp4 -vf fps=1 thumb%04d.jpg -hide_banner`
- Extract only one frame: `ffmpeg -i vid.mp4 -ss 00:00:10.000 -vframes 1 thumb.jpg`
 
 
## Rip streaming media

1. Locate the playlist file, e.g. using Chrome > F12 > Network > Filter: m3u8
2. Download and concatenate the video fragments:

````
ffmpeg -i "path_to_playlist.m3u8" -c copy -bsf:a aac_adtstoasc vid.mp4
````

If you get a "Protocol 'https not on whitelist 'file,crypto'!" error, add the `protocol_whitelist` option:

````
ffmpeg -protocol_whitelist "file,http,https,tcp,tls" -i "path_to_playlist.m3u8" -c copy -bsf:a aac_adtstoasc vid.mp4
````

## Kill audio:

````
ffmpeg -i vid.mp4 -an vid.mp4   
````

## Deinterlace

Deinterlacing using "yet another deinterlacing filter".

````
ffmpeg -i vid.mp4 -vf yadif vid.mp4
````



## Metadata: Change the title

````
ffmpeg -i vid.mp4 -map_metadata -1 -metadata title="My Title" -c:v copy -c:a copy vid.mp4
````

## Deblock and denoise

````
ffmpeg -i vid.mp4 -vf "hqdn3d,deblock" vid.mp4
````

## Adjust speed

Slow-mo:
````
ffmpeg -i vid.mp4 -filter:v "setpts=4.0*PTS" vid.mp4
````
Speed-up:
````
ffmpeg -i vid.mp4 -filter:v "setpts=0.5*PTS" vid.mp4
````

## Stabilize

Make sure you have libvidstab installed with ffmpeg.

````
ffmpeg -i vid.mp4 -vf vidstabdetect -f null -
````
````
ffmpeg -i vid.mp4 -vf vidstabtransform=smoothing=5:input="transforms.trf" vidstab.mp4
````
