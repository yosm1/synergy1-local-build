# Synergy 1 Builds

Unofficial Synergy 1 builds for Windows x64 and Intel macOS.

**[Download Windows MSI / portable ZIP and Intel Mac DMG from Releases](https://github.com/yosm1/synergy1-builds/releases).**
Windows 和 Intel Mac 安装包请前往 [Releases](https://github.com/yosm1/synergy1-builds/releases) 下载。

Not the full Synergy 3 commercial client. No official support is included.

## Downloads

See [Releases](https://github.com/yosm1/synergy1-builds/releases) for installers,
the matching source ZIP and SHA256SUMS.txt.
macOS 14.8.9 is the tested Mac runtime. Windows portable mode omits the service
and cannot control the login screen or UAC secure desktop.

## Source provenance

- Upstream: https://github.com/symless/synergy
- Exact upstream commit: a6281479abf4e991c760fec4b66bbea1d98637ac
- Built version: 1.22.3-dev+a6281479 (Deskflow 1.26, protocol 1.8)
- `source/` is the complete tracked upstream source snapshot, without edits.
- `local-build/` contains the tested build scripts, tool versions and notices.
- Root LICENSE and LICENSE_EXCEPTION are copied from upstream. Third-party
  components retain their own licenses; see local-build/third-party-notices/.

## Rebuilding the exact packages

Read local-build/BUILD-README.md and local-build/README-dev-tools.md first.
The existing scripts retain their tested D:\program Windows tool paths.
They are build scripts, not a complete automated Windows dependency installer.
Install the recorded tools before running them on a new machine.

For an exact version-stamped rebuild, download synergy-source.zip from the
Release. It includes the original pinned Git metadata, which the scripts
check. GitHub's automatic source archives contain this publishing repository's
snapshot, not the original upstream Git metadata, and are not interchangeable
with synergy-source.zip for these scripts.

On Windows, extract synergy-source.zip into D:\program\synergy\src\synergy.
Copy local-build/third-party-notices to D:\program\synergy\third-party-notices
and run local-build/build-windows.ps1 -Msi after setting up the pinned tools.
Do not overwrite an existing source checkout without checking it first.

On Intel Mac, put synergy-source.zip next to local-build/build-mac-intel.sh
and run that script on macOS. Tools/builds live under ~/program by default.
The default Mac deployment target is 12.0, but only macOS 14.8.9 was tested.

Build settings use Release optimization, GUI enabled, upstream local-development
identity, SYNERGY_ENABLE_ACTIVATION=OFF and SYNERGY_VERSION_CHECK=OFF.
No licensing source code is patched. No paid Apple Developer membership was
used; Mac signing is ad-hoc, not Developer ID signing or notarization.

## Verification and limitations

Windows GUI/Core version commands and x64 architecture checks passed. Portable
ZIP CRC and 28 executable/DLL payload comparisons passed. MSI structure and
runtime/service/firewall entries were checked; install/uninstall was not tested.
On the Intel Mac, DMG verification, x86_64 architecture checks, GUI/Core version
commands and strict ad-hoc signature verification passed. Downloaded package
hashes match the built files. Actual two-computer input sharing was not tested.

Windows may show an unknown-publisher prompt. macOS may require approval for a
trusted self-built app, Accessibility and Input Monitoring permissions. Do not
globally disable Gatekeeper. Configure one server and one client, matching screen
names/layout, reachable networking, firewall access and TLS fingerprints.

Only source, build material and final distributables are published. Credentials,
SSH configuration, host addresses, build caches and installed tools are excluded.
Upstream workflows remain under source/.github and are not activated by this repo.
