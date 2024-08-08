# Black Hole - Accessibility/Screenreader mod for Balatro
Black Hole is an accessibility mod for Balatro that adds screen reader support to the game. It was tested on Windows with [NVDA](https://www.nvaccess.org/download/). Other screenreaders supported by [Tolk](https://github.com/dkager/tolk) should also work. If no screenreader is detected, Microsoft SAPI 5 will be used instead **(Not recommended)**. Support for default speech voices on macOS is also included, but has not been tested as of yet.

## How to install Black Hole
1. [Install Balatro on Steam](https://store.steampowered.com/app/2379780/Balatro/) if you haven't already. Wait a few seconds for the music to start playing to ensure the save directory is set up correctly, then close the game.
2. [Create an exclusion](https://github.com/Steamopollys/Steamodded/wiki/01.-Getting-started#using-windows-defender) for Balatro in Windows Security. Lovely is incorrectly flagged as malicious, so it will cause issues if you don't disable it.
3. [Install Lovely](https://github.com/ethangreen-dev/lovely-injector?tab=readme-ov-file#windows--proton--wine).
4. Download the latest source code of [Steamodded](https://github.com/Steamopollys/Steamodded/) using [this direct link](https://github.com/Steamopollys/Steamodded/archive/refs/heads/main.zip). Copy the `Steamodded-main` folder inside the zip file to your clipboard.
5. Press the Windows key + R and type in `%AppData%/Balatro`. In this folder, create a new directory named `Mods`. Paste the `Steamodded-main` folder from your clipboard here.
6. Download the [latest source code of Black Hole](https://github.com/Aurelius7309/BlackHole/archive/refs/heads/main.zip) as well as any other mods you wish to install and add them to your Mods folder.
7. Inside the `BlackHole-main` directory in your Mods folder, look for a `bin` folder. Copy the files inside to your clipboard. Find Balatro's installation directory again by right-clicking the game in Steam, hovering "Manage", and selecting "Browse local files". Paste the binaries from your clipboard into this folder.
8. Launch the game!

## The keyboard controller
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
- [Nopeus](https://github.com/jenwalter666/Nopeus) is An extension of the MoreSpeeds mod for Balatro, including a new speed which reduces delays in the event manager to 0/near-zero.
- [Achievements Enabler](https://github.com/Steamopollys/Steamodded/blob/main/example_mods/Mods/AchievementsEnabler.lua) is an example mod included with Steamodded that re-enables Steam achievements.
- [Dimserene's Modpack](https://github.com/Dimserene/Dimserenes-Modpack) includes a large selection of various mods for you to choose from. Depending on their additions, not all mods may be fully accessible.
## Credits
- https://github.com/dkager/tolk
- https://github.com/pitermach/Love2talk
- https://github.com/ethangreen-dev/lovely-injector
- https://github.com/Steamopollys/Steamodded 
