$env:VCPKG_ROOT = 'D:\program\vcpkg'
$env:VCPKG_DOWNLOADS = 'D:\program\cache\vcpkg-downloads'
$env:VCPKG_DEFAULT_BINARY_CACHE = 'D:\program\cache\vcpkg-binaries'
$env:QT_PATH = 'D:\program\Qt\6.9.3\msvc2022_64'
$env:WIX_EXTENSIONS = 'D:\program\tools\wix-extensions'
$env:NUGET_PACKAGES = 'D:\program\cache\nuget'
$env:DOTNET_CLI_HOME = 'D:\program\tools\dotnet-home'
$env:DOTNET_CLI_TELEMETRY_OPTOUT = '1'
$env:PIP_CACHE_DIR = 'D:\program\cache\pip'
$env:PKG_CONFIG = 'D:\program\tools\pkgconf\mingw64\bin\pkgconf.exe'
# Avoid obsolete MSYS runtime downloads; this native pkgconf is SHA512-verified.
$env:VCPKG_KEEP_ENV_VARS = 'PKG_CONFIG'
$env:PATH = 'D:\program\tools\cmake-3.31.10-windows-x86_64\bin;D:\program\tools\ninja;D:\program\tools\wix;' + $env:QT_PATH + '\bin;' + $env:PATH
# Dot-source this file in future PowerShell sessions; no global PATH overwrite.
