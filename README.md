# signloop-config-toolkit

This is the home repository for `signloop-config`, the configuration folder used by SignLoop digital signage appliances.

## What it does

The `signloop-config/` folder serves dual purposes:
- **On the appliance**: Configuration files read at runtime
- **On Windows**: Tools to create and edit those configurations

Configure locally via USB, or remotely using a one-time code displayed on the appliance.

| Scenario | How |
|----------|-----|
| Direct USB | Insert the appliance's boot drive into a Windows PC |
| Remote | Download toolkit, configure, send via one-time code |

New users can run `Update-SignLoop.bat` to walk through configuration.

## Download

The `signloop-config` folder already exists on each SignLoop appliance and can be edited directly from a USB boot device when connected to a Windows PC.

For remote configuration—or to prepare configurations on a separate workstation before sending to the appliance—download and install the toolkit here:

### PowerShell

```powershell
irm https://raw.githubusercontent.com/signrescue/signloop-config-toolkit/main/scripts/install.ps1 | iex
```

The script will prompt for install location (default: `C:\signloop-config`) and optionally create a Desktop shortcut.

### Manual

Download the latest release from [Releases](https://github.com/signrescue/signloop-config-toolkit/releases) and extract.

---

## Build (for maintainers)

Binaries are excluded from git. Download with `build.bat`. Licenses are in `signloop-config/licenses/`.
