[![License](https://img.shields.io/github/license/kwin/macdependency)](https://www.gnu.org/licenses/gpl-3.0.en.html)
[![Build Status](https://github.com/kwin/macdependency/actions/workflows/build.yml/badge.svg)](https://github.com/kwin/macdependency/actions/workflows/maven.yml)

MacDependency shows all dependent libraries and frameworks of a given executable, dynamic library or framework on Mac OS X. It is a GUI replacement for the otool command, and provides almost the same functionality as the Dependency Walker (http://www.dependencywalker.com) on Windows.

More information available in the [Wiki](../../wiki).

![Screenshot](images/macdependency.png)

## Features

- **Auto-open Example**: When launched without arguments, MacDependency automatically opens and displays its own binary as a working example
- **Command-Line Support**: Open files directly from the command line
- **Multiple Architectures**: View dependencies for different CPU architectures (x86_64, ARM64, etc.)
- **Symbol Table Viewer**: Browse symbol tables and exported functions
- **Dependency Tree**: Hierarchical view of all library dependencies

## Usage

### GUI Usage

Simply double-click `MacDependency.app` or drag a file onto the application icon to analyze it.

When launched without any file, MacDependency will automatically open itself as an example, showing you how the application works.

### Command-Line Usage

You can also launch MacDependency from the command line to analyze specific files:

```bash
# Open a single application
MacDependency.app/Contents/MacOS/MacDependency /Applications/Safari.app

# Open a binary directly
MacDependency.app/Contents/MacOS/MacDependency /bin/ls

# Open multiple files (each opens in a separate window)
MacDependency.app/Contents/MacOS/MacDependency /bin/ls /bin/cat /usr/bin/tar

# Use relative paths
cd /Applications
MacDependency.app/Contents/MacOS/MacDependency Safari.app
```

### Known Limitations: System Libraries

**Important**: On macOS 11 (Big Sur) and later, system frameworks and libraries are **not available as individual files**. They are stored in a prebuilt dyld shared cache for performance.

If you try to analyze system files, you'll see errors like:
```
ERROR: Couldn't open file '/System/Library/Frameworks/Cocoa.framework/Versions/A/Cocoa'
ERROR: Couldn't open file '/usr/lib/libobjc.A.dylib'
```

**This is expected behavior** - these files literally don't exist on disk anymore.

#### What You Can Analyze

✅ **User Applications**: `/Applications/*.app`
✅ **Third-party binaries**: Any non-system executables
✅ **Your own compiled binaries**: Custom built applications
✅ **Older macOS system copies**: If you have pre-Big Sur system libraries

❌ **System frameworks**: `/System/Library/Frameworks/*` (cached)
❌ **System libraries**: `/usr/lib/*` (cached)

#### Workaround for System Libraries

To analyze system libraries, you would need to:
1. Extract them from the dyld shared cache at `/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/*`
2. Use Apple's `dyld_shared_cache_util` tool to extract individual libraries
3. Then analyze the extracted files with MacDependency

Example:
```bash
# Extract libraries from shared cache (requires Full Disk Access)
# This is an advanced operation
dyld_shared_cache_util -extract /tmp/extracted \
  /System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/dyld_shared_cache_arm64e

# Then analyze the extracted libraries
MacDependency.app/Contents/MacOS/MacDependency /tmp/extracted/usr/lib/libobjc.A.dylib
```

## Building

### Requirements
- macOS with Xcode installed
- Command line tools for Xcode

### Build Instructions

To build MacDependency from source:

```bash
cd MacDependency
xcodebuild -project MacDependency.xcodeproj -scheme MacDependency -configuration Release \
  CODE_SIGN_IDENTITY="-" AD_HOC_CODE_SIGNING_ALLOWED=YES clean build
```

The built application will be located at:
```
~/Library/Developer/Xcode/DerivedData/MacDependency-*/Build/Products/Release/MacDependency.app
```

**Note**: The build command includes ad-hoc code signing which is required for the app to run on modern macOS versions. After building, you may need to sign the embedded framework:

```bash
codesign -f -s - ~/Library/Developer/Xcode/DerivedData/MacDependency-*/Build/Products/Release/MacDependency.app/Contents/Frameworks/MachO.framework
codesign -f -s - ~/Library/Developer/Xcode/DerivedData/MacDependency-*/Build/Products/Release/MacDependency.app
```

### Alternative Build Method

You can also open the project in Xcode and build from the IDE:

1. Open `MacDependency/MacDependency.xcodeproj` in Xcode
2. Select the MacDependency scheme
3. Choose Product > Build (⌘B)

### Creating a DMG

After building, you can create a DMG installer using the included script:

```bash
./create_dmg_for_app.sh
```
