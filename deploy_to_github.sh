#!/bin/bash
# 替换 YOUR_USERNAME 为你的GitHub用户名
GITHUB_USERNAME="YOUR_USERNAME"

# 1. 初始化Git仓库
git init

# 2. 添加所有文件
git add .

# 3. 创建第一个提交
git commit -m "Initial commit: Culture Map app"

# 4. 重命名主分支为main
git branch -M main

# 5. 添加远程仓库（替换YOUR_USERNAME）
git remote add origin https://github.com/$GITHUB_USERNAME/culture_map.git

# 6. 推送到GitHub
git push -u origin main
