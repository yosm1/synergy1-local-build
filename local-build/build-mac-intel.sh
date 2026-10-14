#!/bin/bash
set -euo pipefail
# Run on the Intel Mac, not on Windows. Keep tools separate from system Python.
if [[ "$(uname -s)" != Darwin || "$(uname -m)" != x86_64 ]]; then
  echo "This build plan requires an Intel x86_64 Mac." >&2
  exit 1
fi
OUTPUTS="$(cd "$(dirname "$0")" && pwd)"
TOOLS="${DEV_TOOLS_ROOT:-$HOME/program}"
ROOT="${SYNERGY_BUILD_ROOT:-$TOOLS/synergy}"
COMMIT=a6281479abf4e991c760fec4b66bbea1d98637ac
if ! xcode-select -p >/dev/null 2>&1; then
  echo "Install Apple's Command Line Tools with: xcode-select --install" >&2
  exit 1
fi
mkdir -p "$ROOT" "$TOOLS/cache/pip" "$TOOLS/downloads"
export PIP_CACHE_DIR="$TOOLS/cache/pip"
if [[ ! -x "$TOOLS/cmake-3.31.10-macos-universal/CMake.app/Contents/bin/cmake" ]]; then
  cd "$TOOLS/downloads"
  if [[ ! -f cmake-3.31.10-SHA-256.txt ]]; then
    curl --silent --show-error --fail --location --retry 3 --connect-timeout 30 \
      -o cmake-3.31.10-SHA-256.txt \
      https://github.com/Kitware/CMake/releases/download/v3.31.10/cmake-3.31.10-SHA-256.txt
  fi
  if ! grep 'cmake-3.31.10-macos-universal.tar.gz$' cmake-3.31.10-SHA-256.txt | shasum -a 256 -c -; then
    curl --silent --show-error --fail --location --retry 3 --connect-timeout 30 \
      --max-time 900 --continue-at - -o cmake-3.31.10-macos-universal.tar.gz \
      https://github.com/Kitware/CMake/releases/download/v3.31.10/cmake-3.31.10-macos-universal.tar.gz
  fi
  grep 'cmake-3.31.10-macos-universal.tar.gz$' cmake-3.31.10-SHA-256.txt | shasum -a 256 -c -
  tar -xzf cmake-3.31.10-macos-universal.tar.gz -C "$TOOLS"
fi
if [[ ! -x "$TOOLS/ninja/ninja" ]]; then
  cd "$TOOLS/downloads"
  if [[ ! -f ninja-mac-1.12.1.zip ]]; then
    curl --silent --show-error --fail --location --retry 3 --connect-timeout 30 \
      -o ninja-mac-1.12.1.zip \
      https://github.com/ninja-build/ninja/releases/download/v1.12.1/ninja-mac.zip
  fi
  mkdir -p "$TOOLS/ninja"
  unzip -q ninja-mac-1.12.1.zip -d "$TOOLS/ninja"
  chmod +x "$TOOLS/ninja/ninja"
fi
if [[ ! -x "$ROOT/python-env/bin/python" ]]; then
  /usr/bin/python3 -m venv "$ROOT/python-env"
fi
"$ROOT/python-env/bin/python" -m pip install --progress-bar off aqtinstall==3.3.0
QT="$ROOT/Qt/6.9.3/macos"
if [[ ! -x "$QT/bin/macdeployqt" || ! -f "$QT/lib/QtQml.framework/Versions/A/QtQml" ]]; then
  cd "$ROOT"
  "$ROOT/python-env/bin/python" -m aqt install-qt mac desktop 6.9.3 clang_64 \
    -O "$ROOT/Qt" --archives qtbase qttools qtsvg qttranslations qtdeclarative
fi
OPENSSL="$TOOLS/openssl/3.4.1"
if [[ ! -f "$OPENSSL/lib/libssl.a" || ! -f "$OPENSSL/.deployment-target-12-complete" ]]; then
  ARCHIVE="$TOOLS/downloads/openssl-openssl-openssl-3.4.1.tar.gz"
  if [[ ! -f "$ARCHIVE" ]]; then
    curl --fail --location --retry 3 -o "$ARCHIVE" \
      https://github.com/openssl/openssl/archive/openssl-3.4.1.tar.gz
  fi
  mkdir -p "$TOOLS/build"
  if [[ ! -d "$TOOLS/build/openssl-openssl-3.4.1" ]]; then
    tar -xzf "$ARCHIVE" -C "$TOOLS/build"
  fi
  cd "$TOOLS/build/openssl-openssl-3.4.1"
  if [[ -f Makefile ]]; then make clean; fi
  export MACOSX_DEPLOYMENT_TARGET=12.0
  CFLAGS='-mmacosx-version-min=12.0' \
    ./Configure darwin64-x86_64-cc no-shared --prefix="$OPENSSL" --libdir=lib
  make -j4
  make install_sw
  touch "$OPENSSL/.deployment-target-12-complete"
fi
SOURCE="$ROOT/src"
if [[ ! -d "$SOURCE/.git" ]]; then
  if [[ -f "$OUTPUTS/synergy-source.zip" ]]; then
    if [[ -e "$SOURCE" ]]; then
      echo "Source directory already exists without Git metadata; will not overwrite it." >&2
      exit 1
    fi
    mkdir -p "$SOURCE"
    unzip -q "$OUTPUTS/synergy-source.zip" -d "$SOURCE"
  else
    git clone --no-checkout --depth 1 https://github.com/symless/synergy.git "$SOURCE"
    git -C "$SOURCE" fetch --depth 1 origin "$COMMIT"
    git -C "$SOURCE" checkout --detach "$COMMIT"
  fi
fi
if [[ "$(git -C "$SOURCE" rev-parse HEAD)" != "$COMMIT" ]]; then
  echo "Unexpected source revision; will not overwrite your checkout." >&2
  exit 1
fi
export PATH="$QT/bin:$TOOLS/cmake-3.31.10-macos-universal/CMake.app/Contents/bin:$TOOLS/ninja:$PATH"
BUILD="$ROOT/build/mac-x64"
cmake -S "$SOURCE" -B "$BUILD" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES=x86_64 \
  -DCMAKE_PREFIX_PATH="$QT;$OPENSSL" -DOPENSSL_ROOT_DIR="$OPENSSL" \
  -DBUILD_GUI=ON -DBUILD_INSTALLER=ON -DBUILD_OSX_BUNDLE=ON \
  -DBUILD_TESTS=OFF -DBUILD_USER_DOCS=OFF -DBUILD_DEV_DOCS=OFF \
  -DSYNERGY_VERSION_RELEASE=OFF -DSYNERGY_VERSION_SNAPSHOT=OFF \
  -DSYNERGY_ENABLE_ACTIVATION=OFF -DSYNERGY_VERSION_CHECK=OFF \
  '-DSYNERGY_PRODUCT_NAME=Synergy 1 (Local Build)' \
  -DSYNERGY_PACKAGE_PREFIX=synergy1-local
cmake --build "$BUILD" --parallel 4
cd "$BUILD"
cat > "$ROOT/local-sign.cmake" <<'CMAKE'
# Final app-local signing occurs after Qt deployment and license installation.
file(GLOB _apps "${CPACK_TEMPORARY_INSTALL_DIRECTORY}/*.app")
if(NOT _apps)
  message(FATAL_ERROR "No staged application to sign")
endif()
foreach(_app IN LISTS _apps)
  execute_process(COMMAND /usr/bin/codesign --force --deep --sign - "${_app}"
    RESULT_VARIABLE _result)
  if(NOT _result EQUAL 0)
    message(FATAL_ERROR "Ad-hoc application signing failed")
  endif()
endforeach()
CMAKE
cpack -G DragNDrop --config "$BUILD/CPackConfig.cmake" \
  -D "CPACK_RESOURCE_FILE_LICENSE=$SOURCE/LICENSE" \
  -D "CPACK_PRE_BUILD_SCRIPTS=$ROOT/local-sign.cmake"
cp ./*.dmg "$OUTPUTS/"
shasum -a 256 "$OUTPUTS"/*.dmg
echo "DMG created. Local/ad-hoc signing only; not Developer ID notarized."
echo "On the target Mac, grant Accessibility/Input Monitoring permissions as needed."
