@echo off 
@setlocal

set WSL_UTF8=1
setlocal enabledelayedexpansion

set defaultdist=none
set /A isubuntu=0

if not exist "C:\Program Files\Docker\Docker\Docker Desktop.exe" (
  :: Download Docker Desktop
  bitsadmin.exe /transfer "DownloadDocker" "https://desktop.docker.com/win/main/amd64/136059/Docker Desktop Installer.exe" "%temp%\DockerDesktopInstaller.exe"
  :: Install it
  powershell -Command Start-Process "%temp%\DockerDesktopInstaller.exe" -Wait install

  :: Ask the user to restart its computer
  echo 
  echo ------------------------------------------------------------------------------------
  echo Docker Desktop installation completed!
  echo To ensure that all the changes are properly applied, please restart your computer.
  echo Then click the Windows_launcher.
  echo ------------------------------------------------------------------------------------
  pause
  exit
)

:: Check if WSL is installed
for /f "tokens=* USEBACKQ skip=1" %%g in (`wsl --status`) do (set wslworking=%%g)

:: In case is not installed, install it
if ["%wslworking%"]==[""] (
  wsl --install Ubuntu
  
  :: Ask the user to restart its computer
  echo 
  echo ------------------------------------------------------------------------------------
  echo Ubuntu in WSL installation completed!
  echo To ensure that all the changes are properly applied, please restart your computer. 
  echo Then click the Windows_launcher.
  echo ------------------------------------------------------------------------------------
  pause
  exit
)

:: Go trough all the WSL distributions in your computer
for /f "tokens=* USEBACKQ skip=1" %%F in (`wsl --list`) do (

  :: Get distribution name
  set "dist=%%F"

  :: Remove the word Default in that name
  set "defaultless=!dist:Default=!"

  :: Check if the distrubution name contained Default
  if not !dist!==!defaultless! (
    set defaultless=!defaultless:~0,-3!
    set defaultdist=!defaultless!
  )

  :: Remove the word Ubuntu in that name
  set "ubuntuless=!defaultless:Ubuntu=!"

  :: Check if the distrubution name contained Ubuntu
  if !ubuntuless!=="" set /A isubuntu=1
)

:: First check if Ubuntu is installed
if %isubuntu%==0 (
  :: If it is not installed, install Ubuntu
  wsl --install Ubuntu
  wsl --set-default Ubuntu

  :: Ask the user to restart its computer
  echo 
  echo ------------------------------------------------------------------------------------
  echo Ubuntu in WSL installation completed!
  echo To ensure that all the changes are properly applied, please restart your computer. 
  echo Then click the Windows_launcher.
  echo ------------------------------------------------------------------------------------
  pause
  exit
) else (
  :: If it is intalled, check if it is the default distribution
  if not %defaultdist%==Ubuntu (  
    echo No default ubuntu
    :: If not, set as the default one
    wsl --set-default Ubuntu
  )
)

:: At this point Ubuntu is installed and as the default distribution, run the launch.sh inside the WSL
wsl -d Ubuntu bash -E Linux_launch.sh
