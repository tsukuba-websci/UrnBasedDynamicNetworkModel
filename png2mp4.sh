#!/bin/sh

cd imgs
ffmpeg -r 30 -i %05d.png -vcodec libx264 -pix_fmt yuv420p -r 30 -y 00000.mp4