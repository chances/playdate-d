# playdate-d

[![DUB Package](https://img.shields.io/dub/v/playdate.svg)](https://code.dlang.org/packages/playdate)
![Playdate D SDK CI](https://github.com/chances/playdate-d/actions/workflows/ci.yml/badge.svg)
[![codecov](https://codecov.io/gh/chances/playdate-d/branch/main/graph/badge.svg?token=5YN3BU7KR3)](https://codecov.io/gh/chances/playdate-d/)

D bindings to the [Playdate SDK](https://sdk.play.date/1.12.3/Inside%20Playdate%20with%20C.html).

## Usage

```json
"dependencies": {
    "playdate": "1.12.0"
},
"configurations": [
    {
        "name": "simulator",
        "targetType": "dynamicLibrary",
        "postBuildCommands-osx": [
            "mv dist/libpdex.dylib dist/pdex.dylib"
        ],
        "postBuildCommands-posix": [
            "touch dist/pdex.bin",
            "$PLAYDATE_SDK_PATH/bin/pdc $PACKAGE_DIR/dist app.pdx"
        ],
        "postBuildCommands-windows": [
            "pdc $PACKAGE_DIR/dist app.pdx"
        ]
    },
    {
        "name": "device",
        "targetType": "staticLibrary"
    }
  ]
```

## Version Relation to Playdate SDK

Published versions of this library are guaranteed to align with the Playdate SDK for _MAJOR_ **and** _MINOR_ versions.
For example, version `1.12.3` of the library aligns with `1.12.x` versions of the Playdate SDK.
