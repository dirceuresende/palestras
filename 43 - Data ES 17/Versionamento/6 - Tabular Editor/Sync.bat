cd teste-versionamento-tom
git checkout -b development
git fetch origin main
git add .
git commit -m "Daily Integration %date% - %time%"
git pull --rebase origin main
git push -f origin development
pause