# signloop-config-toolkit

Portable Windows toolkit for configuring SignLoop digital signage appliances.

## What it does

The `signloop-config/` folder serves dual purposes:
- **On the appliance**: Configuration files read at runtime
- **On Windows**: Tools to create and edit those configurations

Configure locally via USB, or remotely using a one-time code displayed on the appliance.

| Scenario | How |
|----------|-----|
| Direct USB | Insert the appliance's boot drive into a Windows PC |
| Remote | Download toolkit, configure, send via one-time code |

New users can run `welcome.bat` to walk through configuration.

## Download

### PowerShell

Optionally navigate to where you want it installed, then run:

```powershell
irm https://raw.githubusercontent.com/ORG/signloop-config-toolkit/main/install.ps1 | iex
```

The script will prompt to install elsewhere, like `%USERPROFILE%\signloop-config`, and optionally create a Desktop shortcut.

### Manual

Download the latest release from [Releases](https://github.com/ORG/signloop-config-toolkit/releases) and extract.

---

## Build (for maintainers)

Binaries are excluded from git. Download with `build.bat`. Licenses are in `signloop-config/licenses/`.
