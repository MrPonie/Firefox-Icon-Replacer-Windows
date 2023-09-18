# Firefox-Icon-Replacer-Windows

## What does it do?

As the name implies it replaces firefox icons that are shown in windows desktop, taskbar, file explorer, and icons shown inside firefox browser and it's windows. But unfortunitely it does not change icon shown in windows start if you pin it to start.

## The script as is DOES NOT WORK, why

The batch script relies on **Resource Hacker** to modify firefox executable, inside which there are icons.
You can download Resource Hacker from this URL: <http://www.angusj.com/resourcehacker/>
**KEEP IN MIND** that you will need to write full path to Resource Hacker executable inside batch script.

## How to use

Inside MODIFY folder you will find two more folders: 
- branding (icons inside will be shown inside firefox and it's windows);
- Icons (icons inside will be shown in windows).
Modify those icons as much as you want, just keep the filenames intact.
Then inside batch script make sure that *firefoxDirectory* and *resourceHackerPath* variables are correctly pointing to their respective locations.
Finally run the script (Most likely script will need *administrator privileges* to modify files inside Program Files).

## Things to know:

- The script creates copies of the files inside backup folder before modifying them;
- After running the script you will need to restart Windows Explorer for the icons to update, or restart computer, that will work too;
- After every firefox update you will need to rerun the script again because firefox updater will restore the files modified.

## In case after running the script you need to restore files

You will be able to find original files inside backup folder, which you can find at the same location as this markdown file.
Put *firefox.exe* and *private_browsing.exe* at Firefox directory, which by default is at: `C:\Program Files\Mozilla Firefox\`.
Put *omni.ja* at: `C:\Program Files\Mozilla Firefox\browser\`.