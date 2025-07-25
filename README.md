# Black Hole: An Accessibility/Screenreader mod for Balatro

Black Hole is an accessibility mod for Balatro that adds screen reader support to the game. It was tested on Windows with [NVDA](https://www.nvaccess.org/download/). Other screenreaders supported by [Tolk](https://github.com/dkager/tolk) should also work. If no screenreader is detected, Microsoft SAPI 5 will be used instead **(Not recommended)**. Support for default speech voices on macOS is also included.

## Installation

**Note:** these steps are designed for installation on Windows with the Steam version of Balatro

### Prerequisite Steps

Follow these steps first no matter how you install Black Hole

1. [Install Balatro on Steam](https://store.steampowered.com/app/2379780/Balatro/)
2. Launch the game at least once. After launching, wait for music to start hplaying to ensure the save file directory is set up correctly, then close the game. The save file directory is separate from the installation directory.
3. Get the filepath for the Balatro install directory. The next step includes instructions for doing this in the provided link. By default, Balatro installs to `C:\Program Files (x86)\Steam\steamapps\common\Balatro`.
4. Follow step 1 of the Steamodded installation to [create a Windows Defender Exclusion for Balatro](https://github.com/Steamodded/smods/wiki/Installing-Steamodded-windows#step-1-anti-virus-setup). Lovely, one of the dependancies, is incorrectly flagged as malicious, so it will cause issues if you don't create this exception.

### Full Release Installation

This distribution includes Achievements Enabler, Nopeus and an automatic update script. Make sure you follow the prerequisite steps before proceeding.

1. [Install Git](https://git-scm.com/downloads).
2. Visit the [latest Black Hole release](https://github.com/Aurelius7309/BlackHole/releases/latest) and download BlackHole-Release.zip.
3. Once downloaded, Copy the Mods folder inside the xip file.
4. Open the Windows run dialogue with `Windows key + R` and type in `%AppData%/Balatro`. Press enter to open Balatro's save file directory and paste the Mods folder here.
5. Navigate into the Mods folder and run the update_balatro_mods bat file to download all necessary mods. You may need to pass through a Windows Smartscreen dialogue.
6. Several folders should appear in Mods including blackhole. Navigate into blackhole/bin and copy the dll files.
7. Return to the Balatro installation directory and paste the dll files there.
8. Copy `version.dll` from the zip file you downloaded into the Balatro installation directory.
9. Launch the game!

### Manual Installation

If you want the minimum installation to run Black Hole with no extra mods or auto-update script, follow these steps. Make sure you follow the prerequisite steps before proceeding.

1. Follow the instructions to [install Lovely](https://github.com/ethangreen-dev/lovely-injector?tab=readme-ov-file#windows--proton--wine).
2. Download the latest source code of Steamodded using [this direct link](https://github.com/Steamopollys/Steamodded/archive/refs/heads/main.zip).
3. Copy the `Steamodded-main` folder inside the zip file.
4. Open the Windows run dialogue with `Windows key + R` and type in `%AppData%/Balatro`. In this folder, create a new directory named `Mods` (with a capital M) if it does not already exist. Paste the `Steamodded-main` folder inside the mods folder.
5. Download the [latest source code of Black Hole](https://github.com/Aurelius7309/BlackHole/archive/refs/heads/main.zip). Paste the folder inside of the zip file into the Mods folder. Do this for any other mods you wish to install.
6. Navigate into Mods/blackhole/bin and copy the dll files (Note: the Blachole folder may have a version number in the name).
7. Return to the Balatro installation directory and paste the dll files there.
8. Launch the game!

## Keyboard Mappings

Black Hole allows you to play the game solely with your keyboard by emulating controller inputs. The default keybinds are listed below. If you want to configure different keybinds, press `3` on the main menu.

| Controller button | Default key | Usage |
| ----------------  | ---- | ---- |
| D-Pad up          | W | |
| D-Pad down        | S | |
| D-Pad left        | A | |
| D-Pad right       | D | |
| X                 | X | Play hand / Reroll shop |
| Y                 | C | Start run (in the main menu or while paused) / Discard / Next round (in shop) |
| A                 | Space | Confirm / Select cards (hold to rearrange) |
| B                 | Shift | Cancel / Deselect all cards |
| Start             | Escape | Open Options menu |
| Left Trigger      | Q | Show Deck preview |
| Right Trigger     | E | Open Deck view |
| Left Bumper       | Z | Sell card |
| Right Bumper      | V | Buy card / Use consumable |
| Back              | Tab | Open Run Info |

## Limitations

- The game settings are not yet accessible.
- The game features popups with multiple tabs in some places. You can use the bumpers to switch between tabs, but there is no audio output while doing so. If you move down into the menu and back up to the tab selector, it is however possible to know your current selection.

## Other mods

- [Nopeus](https://github.com/jenwalter666/JensBalatroCollection) is an extension of the MoreSpeeds mod for Balatro, including a new speed which reduces delays in the event manager to 0/near-zero.
- [Achievements Enabler](https://github.com/Steamopollys/Steamodded/blob/main/example_mods/Mods/AchievementsEnabler.lua) is an example mod included with Steamodded that re-enables Steam achievements.
- [Dimserene's Modpack](https://github.com/Dimserene/Dimserenes-Modpack) includes a large selection of various mods for you to choose from. Depending on their additions, not all mods may be fully accessible.

## Credits

- [Tolk](https://github.com/dkager/tolk)
- [Love2talk)(https://github.com/pitermach/Love2talk)
- [Lovely](https://github.com/ethangreen-dev/lovely-injector)
- [Steamodded](https://github.com/Steamopollys/Steamodded)
