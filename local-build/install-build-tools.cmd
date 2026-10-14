@echo off
rem Run this file yourself; the Microsoft installer may request administrator consent.
"D:\program\synergy\downloads\vs_BuildTools.exe" --passive --wait --norestart --nocache --installPath D:\program\BuildTools2022 --path shared=D:\program\VisualStudioShared --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows11SDK.26100 --add Microsoft.VisualStudio.Component.VC.CMake.Project
echo Installer exit code: %ERRORLEVEL%
pause
