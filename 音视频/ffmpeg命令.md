#### ffmpeg



通过命令方式采集音频

`ffmpeg -f avfoundation -i :0 out.wav`

以冒号区分，冒号前为视频，冒号后为音频

上面命令意思：采集音频，音频文件为out.wav



播放

`ffplay out.wav`

