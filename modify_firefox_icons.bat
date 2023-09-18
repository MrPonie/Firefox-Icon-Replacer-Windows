@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: modify variable to match with firefox directory on your machine
set firefoxDirectory="C:\Program Files\Mozilla Firefox"
:: modify variable to match with resource hacker directory
set resourceHackerPath="%~dp0\resource hacker\ResourceHacker.exe"









set archiveToModify=%firefoxDirectory%\browser\omni.ja
set exeToModify=%firefoxDirectory%\firefox.exe
set privateExeToModify=%firefoxDirectory%\private_browsing.exe

set backupToFolder=%~dp0\backup

set modifiedBrandingFolder=%~dp0\MODIFY\branding
set modifiedIcon=%~dp0MODIFY\Icons\icon.ico
set modifiedPrivateIcon=%~dp0MODIFY\Icons\private.ico

set extractToFolder=%~dp0\temporary
set archiveToFile=%~dp0\omni.zip
set resourceHackerScriptPath=%~dp0\rhscript.txt

:: checking if administrative permissions given
echo [WARNING] Administrator permissions required to modify files in %%ProgramFiles%%. Detecting permissions...
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [WARNING] Administrator permissions not detected.
    set /p input=Do you still want to continue execution? [y / n]: 
    if /I not "!input!" == "y" (
        echo [INFO] Stopped execution.
        pause >nul
        exit
    )
) else echo [INFO] Administrator permissions detected.

:: checking if modified branding folder exists
if not exist %modifiedBrandingFolder% (
    echo [Error] Modified branding folder at "%modifiedBrandingFolder%" does not exist.
    pause
    exit 1
)
:: checking if archive file exists
if not exist %archiveToModify% (
    echo [Error] Firefox omni.ja archive at "%archiveToModify%" does not exist.
    pause
    exit 1
)
:: checking if executable file exists
if not exist %exeToModify% (
    echo [Error] Firefox executable at "%exeToModify%" does not exist.
    pause
    exit 1
)
:: checking if private browsing executable file exists
if not exist %privateExeToModify% (
    echo [Error] Firefox executable at "%privateExeToModify%" does not exist.
    pause
    exit 1
)
:: checking if resource hacker path is valid
if not exist %resourceHackerPath% (
    echo [Error] Resource Hacker executable at "%resourceHackerPath%" does not exist.
    pause
    exit 1
)
:: checking if 7zip is available
(where 7z | find /c ":\") > .\cmdout.txt
set /p count=<.\cmdout.txt
if %count%==0 (
    echo [Error] 7z^(7zip^) was not found.
    pause
    exit 1
)
:: checking if xcopy is available
(where 7z | find /c ":\") > .\cmdout.txt
set /p count=<.\cmdout.txt
if %count%==0 (
    echo [Error] xcopy was not found.
    pause
    exit 1
)
del .\cmdout.txt

:: printing variables set before starting
echo,
echo [INFO] Set variables:
echo [INFO] Firefox directory = %firefoxDirectory%
echo [INFO] Archive to modify = %archiveToModify%
echo [INFO] Executable to modify = %exeToModify%
echo [INFO] Private Browsing executable to modify = %privateExeToModify%

:: backing up files before modifying
echo,
echo [INFO] Copying executables and archive file to backup folder at %backupToFolder%.
echo d|xcopy %archiveToModify% %backupToFolder% /y >nul
if %errorLevel% neq 0 (
    echo [ERROR] Failed to copy archive to backup.
    goto cleanup
)
echo d|xcopy %exeToModify% %backupToFolder% /y >nul
if %errorLevel% neq 0 (
    echo [ERROR] Failed to copy executable to backup.
    goto cleanup
)
echo d|xcopy %privateExeToModify% %backupToFolder% /y >nul
if %errorLevel% neq 0 (
    echo [ERROR] Failed to copy private browsing executable to backup.
    goto cleanup
)

echo,
echo [INFO] Changing omni.ja archive's branding icons to change icons inside firefox browser.
echo,

echo [INFO] Extracting omni.ja archive to a temporary folder.
7z x %archiveToModify% -o%extractToFolder% -y >nul
if %errorLevel% neq 0 (
    echo [ERROR] Failed to extract archive to temporary folder.
    goto cleanup
)

echo [INFO] Copying the modified branding folder into extracted archive's branding folder.
echo d|xcopy %modifiedBrandingFolder% %extractToFolder%\chrome\browser\content\branding /y >nul
if %errorLevel% neq 0 (
    echo [ERROR] Failed to replace extracted archive branding folder with modified branding folder.
    goto cleanup
)

echo [INFO] Archiving extracted folder with the new modified branding folder back into an archive.
7z a %archiveToFile% %extractToFolder%\* >nul
if %errorLevel% neq 0 (
    echo [ERROR] Failed to archive temporary folder files back.
    goto cleanup
)

echo [INFO] Copying new archive file to replace old archive file in firefox directory.
echo f|xcopy %archiveToFile% %archiveToModify% /y >nul
if %errorLevel% neq 0 (
    echo [ERROR] Failed to replace old archive file with the modified archive file.
    goto cleanup
)

echo,
echo [INFO] Modifying executables to change icons shown in windows.
echo,

echo [INFO] Generating resource hacker script.
echo [FILENAMES] >%resourceHackerScriptPath%
echo Exe=    backup\firefox.exe >>%resourceHackerScriptPath%
echo SaveAs= firefox.exe >>%resourceHackerScriptPath%
echo [COMMANDS] >>%resourceHackerScriptPath%
echo -addoverwrite %modifiedIcon%, ICONGROUP,1,1033 >>%resourceHackerScriptPath%
echo -addoverwrite %modifiedIcon%, ICONGROUP,32512,1033 >>%resourceHackerScriptPath%
echo -addoverwrite %modifiedPrivateIcon%, ICONGROUP,5,1033 >>%resourceHackerScriptPath%

echo [INFO] Creating a temporary executable, with main icon and private window icon modified.
%resourceHackerPath% -script %resourceHackerScriptPath%
if %errorLevel% neq 0 (
    echo [ERROR] Generated resource hacker script failed execution.
    goto cleanup
)

echo [INFO] Generating resource hacker script.
echo [FILENAMES] >%resourceHackerScriptPath%
echo Exe=    backup\private_browsing.exe >>%resourceHackerScriptPath%
echo SaveAs= private_browsing.exe >>%resourceHackerScriptPath%
echo [COMMANDS] >>%resourceHackerScriptPath%
echo -addoverwrite %modifiedPrivateIcon%, ICONGROUP,1,1033 >>%resourceHackerScriptPath%

echo [INFO] Creating a temporary private browsing executable, with icon modified.
%resourceHackerPath% -script %resourceHackerScriptPath%
if %errorLevel% neq 0 (
    echo [ERROR] Generated resource hacker script failed execution.
    goto cleanup
)

echo [INFO] Copying modified private browsing executable to replace old firefox private browsing executable.
echo f|xcopy %~dp0\private_browsing.exe %privateExeToModify% /y >nul
if %errorLevel% neq 0 (
    echo [ERROR] Failed replacing firefox private browsing executable with the modified private browsing executable.
    goto cleanup
)

echo,
echo [SUCCESS] Successfuly executed commands.
echo [INFO] You need to restart Windows Explorer, which can be done by opening Task Manager, finding Windows Explorer, and pressing restart button. Alternatively restart computer.

:cleanup
echo,
echo [INFO] Deleting temporary files.
if exist %extractToFolder%          echo y|rmdir /s %extractToFolder% >nul
if exist %archiveToFile%            echo y|del %archiveToFile% >nul
if exist %resourceHackerScriptPath% echo y|del %resourceHackerScriptPath% >nul
if exist %~dp0\firefox.exe          echo y|del %~dp0\firefox.exe >nul
if exist %~dp0\private_browsing.exe echo y|del %~dp0\private_browsing.exe >nul

echo,
echo [INFO] Script finished execution.

ENDLOCAL
pause >nul