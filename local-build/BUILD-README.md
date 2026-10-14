# Synergy 1 local builds

Source revision: `a6281479abf4e991c760fec4b66bbea1d98637ac`.
Upstream version at that revision: 1.22.3.
Targets: Windows 11 x64 and Intel x86_64 macOS 14.8.9.

These are self-built Synergy 1 programs, not the complete Synergy 3 retail client.
Build scripts use Release compiler optimization with the upstream local-development
product identity. Activation and automatic update checks are disabled using
upstream CMake options. No licensing code is patched.

## Windows

Tools and caches live under `D:\program`. Existing Git and .NET are reused.
The Microsoft installer and Windows SDK/system components can still occupy C:.

Rebuild from PowerShell:

```powershell
& .\build-windows.ps1 -Msi
```

The scripts pin the source and vcpkg revisions. Use `environment.ps1` to load
the session-specific Qt and WiX extension paths. `toolchain.json` and
`README-dev-tools.md` document reusable tools for future projects.

The portable ZIP must be extracted in full. Run the GUI EXE inside the extracted
directory; do not copy the EXE alone. The portable package intentionally omits
the Windows service, so login-screen/UAC control is unavailable in that variant.
The MSI includes the service and app-local MSVC runtime DLLs.

## Intel Mac

`build-mac-intel.sh` runs on macOS, not on Windows. It uses existing Apple
Command Line Tools and `/usr/bin/python3`, and stores tools under `~/program`.
No Homebrew or paid Apple Developer membership is required for this local build.
Put `synergy-source.zip` next to the script to use the exact offline source.

```bash
bash ./build-mac-intel.sh
```

The resulting DMG contains an application to drag into Applications. Local/ad-hoc
signing is not Developer ID signing or Apple notarization. Follow macOS security
prompts for a trusted self-built app; do not globally disable Gatekeeper.
Grant Accessibility and Input Monitoring permissions if required for input sharing.

## Use and limitations

Choose one computer as server (the computer with the keyboard and mouse), and
the other as client. Both must be on the same reachable network. Configure matching
screen names/layout and TLS fingerprints. Permit Synergy through the firewall
where needed; its default service port is TCP 24800.

Build success, architecture checks and CLI startup are separate from actual
two-computer mouse/keyboard tests. Read the final delivery report for the tests
that were actually performed. Self-built files do not include official product support.

Keep the matching source archive, build scripts, LICENSE, LICENSE_EXCEPTION and
third-party notices when redistributing; comply with their respective licenses.
No SSH password is included in these files.
