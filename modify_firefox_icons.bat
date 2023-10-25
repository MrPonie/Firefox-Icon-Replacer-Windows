@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: modify variable to match with firefox directory on your machine
set firefoxDirectory="C:\Program Files\Mozilla Firefox"
:: modify variable to match with resource hacker directory (only used to modify executables)
set resourceHackerPath="%~dp0\resource hacker\ResourceHacker.exe"
:: set to 0 or 1 depending on whether you want the script to modify icons shown inside firefox browser
set modifyArchive=1
:: set to 0 or 1 depending on whether you want the script to modify icons shown in windows
set modifyExecutables=1









set archiveToModify=%firefoxDirectory%\browser\omni.ja
set exeToModify=%firefoxDirectory%\firefox.exe
set privateExeToModify=%firefoxDirectory%\private_browsing.exe

set backupToFolder=%~dp0backup

set modifiedBrandingFolder=%~dp0MODIFY\branding
set modifiedIcon=%~dp0MODIFY\Icons\icon.ico
set modifiedPrivateIcon=%~dp0MODIFY\Icons\private.ico

set extractToFolder=%~dp0temporary
set archiveToFile=%~dp0omni.zip
set resourceHackerScriptPath=%~dp0rhscript.txt

set winSysFolder=System32
set "batchPath=%~dpnx0"
for %%k in (%0) do set batchName=%%~nk
set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"

echo [INFO] Checking admin privileges.
net session >nul 2>&1
if '%errorlevel%' == '0' ( goto got_privileges ) else ( goto get_privileges )

:get_privileges
    echo [WARNING] Started without admin privileges, trying to elevate.

    echo [INFO] Creating Visual Basic script that elevates privileges.
    if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
    echo Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
    echo args = "ELEV " >> "%vbsGetPrivileges%"
    echo For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
    echo args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
    echo Next >> "%vbsGetPrivileges%"

    echo args = "/c """ + "!batchPath!" + """ " + args >> "%vbsGetPrivileges%"
    echo UAC.ShellExecute "%SystemRoot%\%winSysFolder%\cmd.exe", args, "", "runas", 1 >> "%vbsGetPrivileges%"

    echo [INFO] Elevating privileges with created Visual Basic script.
    "%SystemRoot%\%winSysFolder%\WScript.exe" "%vbsGetPrivileges%" %*
    exit /B
:get_privileges_end

:got_privileges
    :: setting local directory to this file directory
    setlocal & cd /d %~dp0
    :: deleting temporary created vbs file
    if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

echo should be running here...

:modify_archive
    if %modifyArchive%==0 goto modify_archive_end

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

    :: backing up files before modifying
    echo,
    echo [INFO] Copying archive file to backup folder at %backupToFolder%.
    echo d|xcopy %archiveToModify% %backupToFolder% /y >nul
    if %errorLevel% neq 0 (
        echo [ERROR] Failed to copy archive to backup.
        goto cleanup
    )

    echo,
    echo [INFO] Changing omni.ja archive's branding icons to change icons inside firefox browser.
    echo,

    echo [INFO] Extracting omni.ja archive to a temporary folder.
    7z x %archiveToModify% -o%extractToFolder% -y >nul
    rem if %errorLevel% neq 0 (
    rem     echo [ERROR] Failed to extract archive to temporary folder.
    rem     goto cleanup
    rem )

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
:modify_archive_end

:modify_executables
    if %modifyExecutables%==0 goto modify_executables_end

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
    :: checking if xcopy is available
    (where 7z | find /c ":\") > .\cmdout.txt
    set /p count=<.\cmdout.txt
    if %count%==0 (
        echo [Error] xcopy was not found.
        pause
        exit 1
    )
    del .\cmdout.txt

    echo,
    echo [INFO] Copying executables to backup folder at %backupToFolder%.
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

    echo [INFO] Copying modified executable to replace old firefox executable.
    echo f|xcopy %~dp0\firefox.exe %exeToModify% /y >nul
    if %errorLevel% neq 0 (
        echo [ERROR] Failed replacing firefox executable with the modified executable.
        goto cleanup
    )
    echo [INFO] Copying modified private browsing executable to replace old firefox private browsing executable.
    echo f|xcopy %~dp0\private_browsing.exe %privateExeToModify% /y >nul
    if %errorLevel% neq 0 (
        echo [ERROR] Failed replacing firefox private browsing executable with the modified private browsing executable.
        goto cleanup
    )
:modify_executables_end

:cleanup
echo,
echo [INFO] Deleting temporary files.
if exist %extractToFolder%          echo y|rmdir /s %extractToFolder% >nul
if exist %archiveToFile%            echo y|del %archiveToFile% >nul
if exist %resourceHackerScriptPath% echo y|del %resourceHackerScriptPath% >nul
if exist %~dp0\firefox.exe          echo y|del %~dp0\firefox.exe >nul
if exist %~dp0\private_browsing.exe echo y|del %~dp0\private_browsing.exe >nul

echo,
echo [WARNING] You need to restart Windows Explorer, which can be done by opening Task Manager, finding Windows Explorer, and pressing restart button. Alternatively restart computer.

echo,
echo [INFO] Script finished execution.

ENDLOCAL
pause >nul