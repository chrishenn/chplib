# Chris Pwsh Lib (chplib)

A pwsh library to support my standard windows 11 tweaks, debloating, and config

These three repos are meant to be used together:
- https://github.com/chrishenn/unattend
- https://github.com/chrishenn/chplib
- https://github.com/chrishenn/scoops

## usage

This repo is built into a powershell module that can be installed via:
- scoop manifest (https://github.com/chrishenn/scoops)
- powershell gallery (https://www.powershellgallery.com/packages/chplib)

Install via scoop:

```pwsh
scoop bucket add chris https://github.com/chrishenn/scoops
scoop install chris/chplib
```

Install via powershell gallery:

```pwsh
install-module chplib
```

See available functions:

```pwsh
gcm -module chplib
```

The exported types are dot-sourced by ScriptsToProcess on module import; see `chplib/chplib.psd1::ScriptsToProcess` to 
inspect them.

## dev

```pwsh
# manually bump the release version in the `version` file
0.0.9

# generate module metadata and populate into chplib.psm1, chplib.psd1
pwsh -c ./build.ps1

# create a tagged release to kick off a github action
# - build github release for my scoop manifest
# - publish to powershell gallery
#   - note: gallery releases are immutable

# pwsh:
$ver = get-content $pwd\version
# bash:
ver=$(sed '1!d' version)

git tag -a "v$ver" -m "v$ver" 
git push --tags
```

## ref

https://www.powershellgallery.com/packages/BcAdmin/0.0.9/Content/functions%5CUpdate-Psm1FromSource.ps1