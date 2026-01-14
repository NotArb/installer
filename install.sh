#!/bin/bash

# Keep as const values for updater script to parse

JAVA_LINUX_AARCH64_URL="https://download.oracle.com/java/25/latest/jdk-25_linux-aarch64_bin.tar.gz"

JAVA_LINUX_X64_URL="https://download.oracle.com/java/25/latest/jdk-25_linux-x64_bin.tar.gz"

JAVA_MAC_AARCH64_URL="https://download.oracle.com/java/25/latest/jdk-25_macos-aarch64_bin.tar.gz"

JAVA_MAC_X64_URL="https://download.oracle.com/java/25/latest/jdk-25_macos-x64_bin.tar.gz"

# Defined externally
RELEASE_ID=""
JAR_URL=""

download_file() {
  local url="$1"
  local output="$2"

  if command -v curl >/dev/null 2>&1; then
    curl -Lo "$output" "$url"
  elif command -v wget >/dev/null 2>&1; then
    wget -O "$output" "$url"
  else
    echo "Error: Neither wget nor curl is installed."
    exit 1
  fi
}

install() {
  local java_url="$1"

  caller_dir=$(pwd)

  notarb_home="${XDG_DATA_HOME:-$HOME/.local/share}/notarb"
  mkdir -p "$notarb_home"
  cd "$notarb_home"

  pwd

  echo ""
  echo "Downloading Java..."
  echo "$java_url"

  rm -rf java # forcibly remove all installed java's

  mkdir java

  cd java

  temp_jdk_archive=$(mktemp java_archive_XXXXXXXXX)

  download_file "$java_url" "$temp_jdk_archive" || { echo ""; echo "Failed to download Java!"; exit 1; }

  jdk_folder_name=$(tar -tf "$temp_jdk_archive" | grep -om1 'jdk[^/]*')

  tar -xzf "$temp_jdk_archive" || { echo ""; echo "Failed to extract Java archive!"; rm -f "$temp_jdk_archive"; exit 1; }

  mv -f "$temp_jdk_archive" "$jdk_folder_name.tmp"

  cd ..

  echo ""
  echo "Downloading NotArb..."
  echo "$JAR_URL"

  rm -f .notarb-*.jar

  jar_file=".notarb-$RELEASE_ID.jar"

  download_file "$JAR_URL" "$jar_file" || { echo ""; echo "Failed to download NotArb!"; exit 1; }

  echo ""

  if [[ -d "java/$jdk_folder_name/Contents/Home" ]]; then
    java_home="java/$jdk_folder_name/Contents/Home"
  else
    java_home="java/$jdk_folder_name"
  fi

  cd "$caller_dir"

  # todo change org. to com. after upgrade
  "$java_home/bin/java" -cp "$jar_file" org.notarb.Main finish-install "$notarb_home"
}

kernel=$(uname -s | tr '[:upper:]' '[:lower:]')

if [[ "$kernel" == *"linux"* ]]; then
  os="linux"
elif [[ "$kernel" == *"darwin"* ]]; then
  os="mac"
else
  echo "Unsupported OS: $kernel"
   exit 1
fi

arch=$(uname -m | tr '[:upper:]' '[:lower:]')
if [[ "$arch" == "aarch64" || "$arch" == "arm64" ]]; then
   arch="aarch64"
else
   arch="x64"
fi

case "$os-$arch" in
  linux-aarch64)
    install "$JAVA_LINUX_AARCH64_URL"
  ;;
  linux-x64)
    install "$JAVA_LINUX_X64_URL"
  ;;
  mac-aarch64)
    install "$JAVA_MAC_AARCH64_URL"
  ;;
  mac-x64)
    install "$JAVA_MAC_X64_URL"
  ;;
esac