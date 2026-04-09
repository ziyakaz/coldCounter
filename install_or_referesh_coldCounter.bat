@echo off
SETLOCAL EnableDelayedExpansion

REM ==================================================
REM Check if Python is installed
REM ==================================================
python -c "import sys; exit(0 if sys.version_info >= (3,12) else 1)" >nul 2>&1
IF ERRORLEVEL 1 (

    REM Download Python installer
	echo Python 3.12+ not found. Downloading Python 3.12...
    set "PYTHON_INSTALLER=%TEMP%\python-installer.exe"
	powershell -Command "Invoke-WebRequest -UseBasicParsing -Uri 'https://www.python.org/ftp/python/3.12.2/python-3.12.2-amd64.exe' -OutFile '!PYTHON_INSTALLER!'"
	IF ERRORLEVEL 1 (
		echo ERROR: Python download failed.
		goto :end
	)
	IF NOT EXIST "!PYTHON_INSTALLER!" (
		echo ERROR: Python installer not found.
		goto :end
	)

    REM Install Python silently and add to PATH
	choice /M "Install Python for all users (requires admin)? "
	IF ERRORLEVEL 2 (
		echo Installing Python 3.12 for current user silently...
		start /wait "" "!PYTHON_INSTALLER!" /quiet PrependPath=1 Include_test=0
	) ELSE (
		net session >nul 2>&1
		IF ERRORLEVEL 1 (
			echo ERROR: Please run this script as administrator to install for all users.
			goto :end
		)
		echo Installing Python 3.12 for all users silently...
		start /wait "" "!PYTHON_INSTALLER!" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
	)
	IF ERRORLEVEL 1 (
		echo ERROR: Python installation failed.
	) ELSE (
		echo Python installation completed.
		echo Please start a new terminal session and run this script again.
	)
	
    goto :end
	
) ELSE (
    echo Python is already installed.
)

REM ==================================================
REM  Upgrade pip and install dependencies
REM ==================================================
echo Upgrading pip...
python -m pip install --upgrade pip

IF EXIST requirements.txt (
    echo Installing dependencies from requirements.txt...
    python -m pip install -r requirements.txt
) ELSE (
    echo No requirements.txt found. Skipping dependency install.
)

REM ==================================================
REM  Run the Python script
REM ==================================================
echo Running build_coldCounter.py...
cd /d "%~dp0\code"
python build_coldCounter.py

:end
REM ==================================================
REM Keep terminal open
REM ==================================================
echo.
pause
ENDLOCAL
