# Reusable development tools

Created for the Synergy 1 local-source build on 2026-10-14.

Machine-readable paths: `D:\program\toolchain.json`.
PowerShell session setup: `. D:\program\environment.ps1`.
User environment variable: `CODEX_DEV_TOOLS_ROOT=D:\program`.

## Tools

- MSVC 2022 Build Tools: `D:\program\BuildTools2022`.
- CMake 3.31.10: `D:\program\tools\cmake-3.31.10-windows-x86_64\bin`.
- Ninja 1.12.1: `D:\program\tools\ninja`.
- Qt 6.9.3 (MSVC 2022 x64): `D:\program\Qt\6.9.3\msvc2022_64`.
- vcpkg: `D:\program\vcpkg`, pinned to `d5ec528843d29e3a52d745a64b469f810b2cedbf`.
- vcpkg executable: release `2025-02-11`, matching that checkout's metadata schema.
- Python 3.12.10 embedded: `D:\program\Python312\python.exe`.
- aqtinstall 3.3.0: `D:\program\tools\aqt-python`.
- WiX 5.0.2: `D:\program\tools\wix`.
- WiX extensions: `D:\program\tools\wix-extensions`.
- Existing Git and .NET are reused, not reinstalled.

The embedded Python is for tooling, not a full user Python installation.
It has no pip; its `_pth` file enables the aqt packages in `tools\aqt-python`.
For general Python development, create a separate normal Python environment.

## Compatibility and future tasks

The user PATH adds CMake, Ninja and WiX without removing existing entries.
Qt is intentionally not added globally, to avoid mixing Qt builds across projects.
Use matching MSVC/Qt architectures. Do not feed MSVC Qt libraries to MinGW.
Load the session environment before invoking WiX, so it finds its extensions.
Use a separate vcpkg checkout when a future project requires a different baseline;
do not update this pinned checkout while a build uses it.
Use separate build directories for each architecture and configuration.

## Project and caches

- Source: `D:\program\synergy\src\synergy`.
- Windows build: `D:\program\synergy\build\windows-x64`.
- Scripts: `D:\program\synergy\scripts`.
- Build logs: `D:\program\synergy\logs`.
- Installer/download files: `D:\program\synergy\downloads`.
- Shared caches: `D:\program\cache`.

Visual Studio's installer, Windows SDK/system components, existing .NET,
and some operating-system caches may still use C:. Do not move those manually.
No SSH passwords are stored here. SSH host records are project-scoped.
