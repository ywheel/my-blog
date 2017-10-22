#!/bin/bash
# deploy to github and coding.net
# 1. deploy to github
cd public
git checkout master
git pull origin master
cd ..
hugo
cd public
git add --all
git commit -m "Auto added all changes."
git push origin master
# 2. deploy to coding.net
git checkout coding
git pull coding master
cd ..
hugo --baseURL "http://blog.ywheel.cn"
cd public
git add --all
git commit -m "Auto added all changes."
git push coding coding:master
