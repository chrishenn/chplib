# Chris Pwsh Lib (chplib)

A pwsh library to support my standard windows 11 tweaks, debloating, and config

These three repos are meant to be used together:
- https://github.com/chrishenn/unattend
- https://github.com/chrishenn/chplib
- https://github.com/chrishenn/scoops

This repo is built into a powershell module that can be installed via my scoop bucket and manifest, if you use scoop:

```pwsh
scoop bucket add chris https://github.com/chrishenn/scoops
scoop install chris/chplib
```

This repo is also built into a powershell module that is published to the powershell gallery, installable as:

```pwsh
install-module chplib
```

See available functions

```pwsh
gcm -module chplib
```

The exported types are dot-sourced by ScriptsToProcess on module import; see chplib/chplib.psd1/ScriptsToProcess
to inspect them.

---

## dev

```pwsh
# manually bump the release version in the build.ps1 script
'ModuleVersion' = '0.0.5';

# generate module metadata and populate into chplib.psd1
pwsh -c ./build.ps1

# manually copy-paste the list of function names from chplib.psd1 into chplib.psm1
# push changes to remote

# create a tagged release to kick off a github release for my scoop manifest, and publish to powershell gallery
# note that gallery releases are immutable
git tag -a v0.0.5 -m v0.0.5 -f && git push --tags -f
```

## ref

https://www.powershellgallery.com/packages/BcAdmin/0.0.9/Content/functions%5CUpdate-Psm1FromSource.ps1