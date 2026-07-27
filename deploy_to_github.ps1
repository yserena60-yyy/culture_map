# 替换 YOUR_USERNAME 为你的GitHub用户名
$GITHUB_USERNAME = "YOUR_USERNAME"

Write-Host "Step 1: Initializing Git repository..." -ForegroundColor Green
git init

Write-Host "`nStep 2: Adding all files..." -ForegroundColor Green
git add .

Write-Host "`nStep 3: Creating first commit..." -ForegroundColor Green
git commit -m "Initial commit: Culture Map app"

Write-Host "`nStep 4: Renaming branch to main..." -ForegroundColor Green
git branch -M main

Write-Host "`nStep 5: Adding remote repository..." -ForegroundColor Green
git remote add origin "https://github.com/$GITHUB_USERNAME/culture_map.git"

Write-Host "`nStep 6: Pushing to GitHub..." -ForegroundColor Green
git push -u origin main

Write-Host "`n✅ Done! Check your repository at: https://github.com/$GITHUB_USERNAME/culture_map" -ForegroundColor Cyan
