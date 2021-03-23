# Developer Bash Tools

A collection of bash scripts to automate repetitive tasks.

## Installation

1. Clone this repo in your _home directory_
```bash
git clone https://github.com/StefanoFrazzetto/DevBashTools
```

2. Append the following to your `.bash_profile`
```bash
for f in ~/tools/*.sh; do source $f; done
```

3. Open Git Bash and start using the tools, e.g.
```bash
$ adb_screenshot
```

## ADB

Take a screenshot or record a video through ADB of a device connected via USB.

Screenshot
```bash
$ adb_screenshot
```

Record screen
```bash
$ MSYS_NO_PATHCONV=1 adb_record_screen
```
Note: `MSYS_NO_PATHCONV=1` is used to prevent MSys from translating paths; details [here](https://stackoverflow.com/a/34386471).
