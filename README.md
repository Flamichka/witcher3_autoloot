# AutoLoot for The Witcher 3 Remastered

Automatically collect available loot near Geralt. Version 0.2, English settings.

Under **Settings → Mods → AutoLoot**:

- **Enable AutoLoot**: turn automatic looting on or off.
- **AutoLoot radius (m)**: select 1–6 metres in 1-metre steps.

Defaults: enabled, 3 metres. Settings are read every 0.1 seconds while gameplay allows interaction. Applied changes take effect without restarting the game. The script also clamps the radius to 1–6 metres when settings are edited manually.

## Installation

Close the game. Copy both `Mods` and `bin` into the game's root directory, replacing this mod's previous files. The mod does not replace original game scripts.

If your installation contains `dx11filelist.txt` and `dx12filelist.txt` under `bin/config/r4game/user_config_matrix/pc`, add `modAutoLoot3mRemastered.xml;` on its own line to each file if it is not already listed. Preserve all existing entries. These lists were absent from the installation inspected during development; do not create single-entry lists or remove existing menus.

Use the mod page's reset option to restore defaults. The standard game settings menu handles saving changes.

## Implementation and validation

The TOGGLE and SLIDER formats, GetVarValue and StringToFloat were checked against the installed Remastered scripts. The XML parses correctly and its identifiers match those used by the script. Labels use the standard nonLocalizedName tag; a separate menu wrapper sets the page title.

**Game compilation and menu rendering have not been verified.** The sources were checked against installed executable build 5.0.0.1044392. This is a source release requiring in-game testing.

The mod uses the standard TakeAllItems transfer and OnContainerClosed processing. Locked and disabled containers are skipped. Equivalent guard reactions to manual theft have not been verified.

## In-game checks

1. Disable AutoLoot and approach a full chest: its items should remain. Enable AutoLoot: items should transfer.
2. With a 1-metre radius, an object 2 metres away should remain full. With a 6-metre radius, it should be collected.
3. Restart the game and check that both settings persist.

## Repository layout

- `Mods/`: WitcherScript sources.
- `bin/`: settings menu XML.
- `README_RU.md`: original Russian installation notes.

No original game files are included.
