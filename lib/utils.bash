#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/jonas/tig"
NCURSES_GH_REPO="https://github.com/mirror/ncurses"
NCURSES_VERSION="6.2"
TOOL_NAME="tig"
TOOL_CMD="tig"

fail() {
  echo -e "asdf-$TOOL_NAME: $*"
  exit 1
}

curl_opts=(-fsSL)

sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
  git ls-remote --tags --refs "$GH_REPO" |
    grep -o 'refs/tags/tig-.*' | cut -d/ -f3- |
    sed 's/^tig-//'
}

list_all_versions() {
  list_github_tags
}

install_libncurses() {
  local version="$1"
  local install_path="$2/ncurses"
  local tmp_download_dir="$3"
  local concurrency="$4"

  # Download tar.gz file
  local url="$NCURSES_GH_REPO/archive/refs/tags/v${version}.tar.gz"
  local release_file="$tmp_download_dir/ncurses-${version}.tar.gz"
  echo "* Downloading libncurses release $version..."
  curl "${curl_opts[@]}" -o "$release_file" -C - "$url" || fail "Could not download $url"

  # Extract contents of tar.gz file
  local download_path="$tmp_download_dir/ncurses-$version"
  mkdir -p "$download_path"
  echo "* Extracting $release_file..."
  tar -xzf "$release_file" -C "$download_path" --strip-components=1 || fail "Could not extract $release_file"

  # Build
  cd "$download_path"
  echo "* Building libncurses with prefix $install_path..."
  ./configure --prefix="$install_path" || fail "Could not build libncurses"

  # Install
  echo "* Installing libncurses..."
  make install || fail "Could not install libncurses"
}

install_tig() {
  local version="$1"
  local install_path="$2"
  local tmp_download_dir="$3"
  local concurrency="$4"

  # Download tar.gz file
  local release_file="$tmp_download_dir/$TOOL_NAME-${version}.tar.gz"
  local url="$GH_REPO/releases/download/tig-${version}/tig-${version}.tar.gz"
  echo "* Downloading $TOOL_NAME release $version..."
  curl "${curl_opts[@]}" -o "$release_file" -C - "$url" || fail "Could not download $url"

  # Extract contents of tar.gz file
  local download_path="$tmp_download_dir/${TOOL_NAME}-$version"
  mkdir -p "$download_path"
  echo "* Extracting $release_file..."
  tar -xzf "$release_file" -C "$download_path" --strip-components=1 || fail "Could not extract $release_file"

  # Build
  cd "$download_path"
  echo "* Building $TOOL_NAME with LDFLAGS $install_path/ncurses/lib and CPPFLAGS $install_path/ncurses/include..."
  ./configure LDFLAGS=-L"$install_path/ncurses/lib" CPPFLAGS=-I"$install_path/ncurses/include" || fail "tig build failed"

  # Install
  echo "* Installing $TOOL_NAME..."
  make -j "$concurrency" || fail "Could not conduct make $TOOL_NAME"
  make install prefix="$install_path" || fail "Could not install $TOOL_NAME"
  local binary_path="$install_path/bin"
  test -x "$binary_path/$TOOL_CMD" || fail "Expected $binary_path/$TOOL_CMD to be executable."
  echo "* $TOOL_NAME $version installation was successful!"
}

install_version() {
  local version="$1"
  local install_path="$2"
  local concurrency="$3"

  # Temporary directory to download and build the tool
  TMP_DOWNLOAD_DIR=$(mktemp -d -t tig_build_XXXXXX)
  echo "* Created a directory $TMP_DOWNLOAD_DIR to download and build the tool"
  cleanup() { rm -rf "$TMP_DOWNLOAD_DIR"; }
  trap cleanup ERR EXIT

  (
    install_libncurses "$NCURSES_VERSION" "$install_path" "$TMP_DOWNLOAD_DIR" "$concurrency"
    install_tig "$version" "$install_path" "$TMP_DOWNLOAD_DIR" "$concurrency"
  ) || (
    rm -rf "$install_path"
    fail "An error ocurred while installing $TOOL_NAME $version."
  )
}
