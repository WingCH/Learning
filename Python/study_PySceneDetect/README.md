
從每個偵測到的場景中儲存影像
https://www.scenedetect.com/docs/latest/cli.html#save-images
```
scenedetect -i iShot_2025-04-15_22.31.58.mp4 save-images -o output_folder -n 1
```


生成統計檔案
```
scenedetect -i video.mp4 --stats video_stats.csv detect-adaptive
```