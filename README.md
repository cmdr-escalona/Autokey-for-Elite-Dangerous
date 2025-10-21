# Autokey for Elite Dangerous

An AutoHotkey v1 script that toggles a **Combat Mode** layout for _Elite Dangerous_, providing reliable key sequences, modifier cleanup, and an on-screen status indicator. The script is designed to make multi-step ship commands consistent and to prevent stuck keys when switching between flight and combat controls.

## Features
- **Combat Mode toggle** bound to the <code>`</code> key with a red on-screen overlay.
- **Safe key sending** using `SendInput` and configurable press/delay timings.
- **Modifier guard** that monitors and releases stuck modifier keys while the mode is active.
- **Custom macro hotkeys** for common combat actions, including reliable F4/F5 pause handling.
- **Automatic cleanup** of all modifiers when leaving combat mode or exiting the script.

## Requirements
- Windows 10 or later.
- [AutoHotkey v1.1.33+](https://www.autohotkey.com/) (the script is written for the legacy v1 syntax).
- Elite Dangerous running in the foreground (`EliteDangerous64.exe`).

## Installation
1. Install AutoHotkey v1 if it is not already present.
2. Download or clone this repository.
3. Double-click `Autokey-for-Elite-Dangerous.ahk` to launch the script.
   - The script auto-elevates to Administrator to ensure it can send inputs to Elite Dangerous. Accept the prompt when it appears.

## Usage
1. Launch Elite Dangerous and make sure it is the active window.
2. Press <code>`</code> to toggle Combat Mode on or off.
   - When Combat Mode is active, a red **COMBAT MODE** indicator appears at the top-right of your primary monitor.
3. While Combat Mode is active, the following hotkeys are remapped:

| Hotkey        | Action Description |
|---------------|-------------------|
| `F`           | Sequence `Down → Left → Up → Up → Up` |
| `R`           | Sends `Y` |
| `Left Alt`    | Sequence `Down → Up → Up → Right → Right` |
| `/`           | Sequence `Down → Left → Left → Right → Right` |
| `5`           | Sequence `L → Home` (longer press) |
| `Tab`         | Holds `Tab`, taps middle mouse button, releases `Tab` |
| `Right Mouse` | Sequence `Down → Up → Right → Right → Right → Right Mouse` |
| `Mouse X1`    | Sequence `Down → Up → Left → Left → Left` |
| `Mouse X2`    | Sequence `Down → Up → Right → Right → Right` |
| `F4`          | Pause macro: `F4` tap, wait 2s, `F5` tap, wait 4s, `F5` tap |

4. Press <code>`</code> again to disable Combat Mode and restore the original controls.

### Modifier Guard
A background timer releases any modifier key (Ctrl, Alt, Shift, Win) that appears logically pressed but is not physically held. This prevents stuck modifiers caused by Alt-Tabbing or lost focus events.

### Customization
- Adjust timing: Change the default values in `SendKeyEvents(keys, holdMs := 80, interDelayMs := 35)` for longer or shorter key presses.
- Modify or add hotkeys within the `#If keySwapActive` block.
- Update the `UpdateGuiState()` function to tweak colors, fonts, or overlay position.

## Troubleshooting
- **Script will not start:** Ensure you have AutoHotkey v1 installed. The v2 executable is not compatible.
- **Inputs do not register in-game:** Confirm that Elite Dangerous is focused and that the script is running as Administrator.
- **Overlay does not appear:** Verify that Combat Mode is toggled on and that no other overlay-management software is hiding AutoHotkey GUIs.

## License
This project is released under the MIT License. See [LICENSE](LICENSE) for details.
