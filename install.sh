#!/bin/bash

JAVA_LINUX_AARCH64_URL="https://download.oracle.com/java/25/latest/jdk-25_linux-aarch64_bin.tar.gz"
JAVA_LINUX_AARCH64_PATH="bin/java"

JAVA_LINUX_X64_URL="https://download.oracle.com/java/25/latest/jdk-25_linux-x64_bin.tar.gz"
JAVA_LINUX_X64_PATH="bin/java"

JAVA_MAC_AARCH64_URL="https://download.oracle.com/java/25/latest/jdk-25_macos-aarch64_bin.tar.gz"
JAVA_MAC_AARCH64_PATH="Contents/Home/bin/java"

JAVA_MAC_X64_URL="https://download.oracle.com/java/25/latest/jdk-25_macos-x64_bin.tar.gz"
JAVA_MAC_X64_PATH="Contents/Home/bin/java"

JAR_URL="" # defined by install.js

# 1. Download/Check Java
# 2. Parse latest.txt for latest jar url <-- issue with this is if a latest release is deleted...
# BEST approach is to parse https://api.github.com/repos/NotArb/Jupiter/releases/latest but requires json reader...
# todo lookup common installer methods that require json parsing...

# 3. Download Jar from raw.github/.../latest.txt <-- or just make a notarb.com/latest url that parses

# 2. Download Latest Jar url
# 3. Run Jar with finish-install flag