Stop-Process -Name "dart" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "flutter" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "chrome" -Force -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
Write-Host "Locked background processes cleared and build folder deleted!" -ForegroundColor Green
