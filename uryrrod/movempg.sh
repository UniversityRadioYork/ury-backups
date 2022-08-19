#!/usr/bin/env bash

cd /home/motion
rsync -a --remove-sent-files --files-from=<(find . -mtime +8m -name "*.mpg") . urysteve.ury:/filestore/Webcams