# Mac OS MOTD
My personal MOTD configuration for Mac OS and ZSH.

## Screenshot
![screenshot1](/images/screen2.png)

## Pre-requirements
#### 1. figlet
Needed to generate the banner text.
**Installation:**
```bash
brew install figlet
```
#### 2. icalBuddy
Needed to get events from the Calendar application.
**Installation:**
```bash
brew install ical-buddy
```
#### 3. osx-cpu-temp
Needed to gather CPU and GPU temperature.
**Installation:**
```bash
brew install osx-cpu-temp
```
#### 4. smartmontools
Needed to gather disk temperature.
**Installation:**
```bash
brew install smartmontools
```

## Installation
1. Clone the repository.
```bash
git clone git@github.com:douz/mac-motd.git
```
2. Add the `motd.sh` script at the end of your `.zshrc` file.
```bash
echo "/full/path/to/repo/mac-motd/motd.sh" >> ~/.zshrc
```
3. Restart your terminal.

## Modules
The modules are located in the `modules` directory. You can select which modules to use and their order in `motd.sh`
```bash
# Set modules to load
modulesArray=(banner temperature hdd_usage battery calendar_events)
```

You can add your own custom modules just by placing your `.sh` scripts in the `modules` directory and include them in the `modulesArray` variable without the `.sh` extension in `motd.sh`

### Banner module
You can set your own banner message by replacing the value of the variable `bannerText` in `modules/banner.sh`.

## Support and contribution
For support and/or contributions, open an issue on this repository or contact `dbarahona@me.com`