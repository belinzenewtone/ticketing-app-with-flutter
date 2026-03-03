#!/bin/bash
set -e
curl -sLo flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.35.4-stable.tar.xz
tar xf flutter.tar.xz
export PATH="$PATH:$(pwd)/flutter/bin"
flutter config --no-analytics
flutter pub get
flutter build web --release
