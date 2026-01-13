#!/bin/bash

# Keep as const values for updater script to parse

JAVA_LINUX_AARCH64_URL="https://download.oracle.com/java/25/latest/jdk-25_linux-aarch64_bin.tar.gz"
JAVA_LINUX_AARCH64_PATH="bin/java"

JAVA_LINUX_X64_URL="https://download.oracle.com/java/25/latest/jdk-25_linux-x64_bin.tar.gz"
JAVA_LINUX_X64_PATH="bin/java"

JAVA_MAC_AARCH64_URL="https://download.oracle.com/java/25/latest/jdk-25_macos-aarch64_bin.tar.gz"
JAVA_MAC_AARCH64_PATH="Contents/Home/bin/java"

JAVA_MAC_X64_URL="https://download.oracle.com/java/25/latest/jdk-25_macos-x64_bin.tar.gz"
JAVA_MAC_X64_PATH="Contents/Home/bin/java"

# defined externally
JAR_ID=""
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
  local java_path="$2"

  caller_dir=$(pwd)

  app_dir="${XDG_DATA_HOME:-$HOME/.local/share}/notarb"
  mkdir -p "$app_dir"
  cd "$app_dir"

  pwd

  echo ""
  echo "Downloading Java..."
  echo "$java_url"

  temp_java_archive=$(mktemp java_archive_XXXXXXXXX)

  download_file "$java_url" "$temp_java_archive" || { echo ""; echo "Failed to download Java!"; exit 1; }

  java_folder=$(tar -tf "$temp_java_archive" | grep -om1 'jdk[^/]*')

  rm -rf "$java_folder"

  tar -xzf "$temp_java_archive" || { echo ""; echo "Failed to extract Java archive!"; rm -f "$temp_java_archive"; exit 1; }

  mv -f "$temp_java_archive" "$java_folder.tmp"

  echo ""
  echo "Downloading NotArb..."
  echo "$JAR_URL"

  rm -f .notarb-*.jar

  jar_file=".notarb-$JAR_ID.jar"

  download_file "$JAR_URL" "$jar_file" || { echo ""; echo "Failed to download NotArb!"; exit 1; }

  echo ""

  # todo change org. to com. after upgrade
  exec "$java_folder/$java_path" -cp "$jar_file" org.notarb.Main finish-install "$caller_dir" "$(pwd)" "$java_folder" "$java_path" "$jar_file"
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
    install "$JAVA_LINUX_AARCH64_URL" "$JAVA_LINUX_AARCH64_PATH"
  ;;
  linux-x64)
    install "$JAVA_LINUX_X64_URL" "$JAVA_LINUX_X64_PATH"
  ;;
  mac-aarch64)
    install "$JAVA_MAC_AARCH64_URL" "$JAVA_MAC_AARCH64_PATH"
  ;;
  mac-x64)
    install "$JAVA_MAC_X64_URL" "$JAVA_MAC_X64_PATH"
  ;;
esac