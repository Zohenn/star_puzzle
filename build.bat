rem cmd /c flutter build apk --target-platform=android-arm64 --profile --no-tree-shake-icons
cmd /c flutter build apk --target-platform=android-arm64 --no-shrink --no-tree-shake-icons
cd build/app/outputs/flutter-apk/
del star-puzzle.apk
ren app-release.apk star-puzzle.apk
