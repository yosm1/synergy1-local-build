param([switch]$Msi)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\environment.ps1"
$source = 'D:\program\synergy\src\synergy'
$build = 'D:\program\synergy\build\windows-x64'
$expectedCommit = 'a6281479abf4e991c760fec4b66bbea1d98637ac'
$actualCommit = (& git -C $source rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0 -or $actualCommit -ne $expectedCommit) {
    throw 'The source commit differs from the tested build plan. Review before rebuilding.'
}
$vcpkgCommit = (& git -C $env:VCPKG_ROOT rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0 -or $vcpkgCommit -ne 'd5ec528843d29e3a52d745a64b469f810b2cedbf') {
    throw 'This build requires the pinned vcpkg checkout recorded in toolchain.json.'
}
$devcmd = 'D:\program\BuildTools2022\Common7\Tools\VsDevCmd.bat'
if (!(Test-Path $devcmd)) {
    $vswhere = 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe'
    if (Test-Path $vswhere) {
        $vs = & $vswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
        if ($vs) { $devcmd = Join-Path $vs 'Common7\Tools\VsDevCmd.bat' }
    }
}
if (!(Test-Path $devcmd)) { throw 'Install Microsoft C++ Build Tools using install-build-tools.cmd first.' }
$cmd = '"' + $devcmd + '" -arch=x64 -host_arch=x64 >nul && set'
$vars = & $env:ComSpec /d /s /c $cmd
if ($LASTEXITCODE -ne 0) { throw 'MSVC environment initialization failed.' }
foreach ($line in $vars) {
    if ($line -match '^([^=]+)=(.*)$') { [Environment]::SetEnvironmentVariable($matches[1], $matches[2], 'Process') }
}
foreach ($tool in 'cl.exe', 'cmake.exe', 'ninja.exe', 'windeployqt.exe') {
    if (!(Get-Command $tool -ErrorAction SilentlyContinue)) { throw "Missing tool: $tool" }
}
if (!(Test-Path "$env:VCPKG_ROOT\vcpkg.exe")) { throw 'vcpkg has not been bootstrapped.' }
New-Item -ItemType Directory -Force $build,$env:VCPKG_DOWNLOADS,$env:VCPKG_DEFAULT_BINARY_CACHE | Out-Null
function Invoke-Checked([string]$Exe, [string[]]$Arguments) {
    & $Exe @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$Exe failed with exit code $LASTEXITCODE" }
}
# Release optimizations, but keep the upstream local-development identity.
# Activation is an upstream build option, not a patch to a commercial binary.
Invoke-Checked cmake @('-S', $source, '-B', $build, '-G', 'Ninja',
    '-DCMAKE_BUILD_TYPE=Release', '-DBUILD_TESTS=OFF', '-DBUILD_USER_DOCS=OFF',
    '-DBUILD_DEV_DOCS=OFF', '-DBUILD_GUI=ON', '-DBUILD_INSTALLER=ON',
    '-DSYNERGY_VERSION_RELEASE=OFF', '-DSYNERGY_VERSION_SNAPSHOT=OFF',
    '-DSYNERGY_ENABLE_ACTIVATION=OFF', '-DSYNERGY_VERSION_CHECK=OFF',
    '-DSYNERGY_PRODUCT_NAME=Synergy 1 (Local Build)', '-DSYNERGY_PACKAGE_PREFIX=synergy1-local',
    "-DCMAKE_PREFIX_PATH=$env:QT_PATH", "-DCMAKE_TOOLCHAIN_FILE=$env:VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake",
    '-DVCPKG_TARGET_TRIPLET=x64-windows')
Invoke-Checked cmake @('--build', $build, '--parallel', '8')
Push-Location $build
try {
    Invoke-Checked cpack @('-G', 'ZIP', '--config', "$build\CPackConfig.cmake",
        '-D', "CPACK_PRE_BUILD_SCRIPTS=$build/deploy/pre-cpack.cmake;$PSScriptRoot/package-notices.cmake")
    if ($Msi) {
        if (!(Get-Command wix.exe -ErrorAction SilentlyContinue)) { throw 'WiX is missing.' }
        Invoke-Checked cpack @('-G', 'WIX', '--config', "$build\CPackConfig.cmake",
            '-D', "CPACK_WIX_LICENSE_RTF=$PSScriptRoot/local-build-license.rtf",
            '-D', "CPACK_PRE_BUILD_SCRIPTS=$PSScriptRoot/msi-runtime.cmake")
    }
    Get-ChildItem $build -File | Where-Object Extension -in '.zip','.msi' | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination $PSScriptRoot
    }
} finally { Pop-Location }
Get-ChildItem $PSScriptRoot -File | Where-Object Extension -in '.zip','.msi' | Get-FileHash -Algorithm SHA256
