# MakeRepo

Use MakeRepo to generate a command line tool for creating remote GitHub repos.

## Usage

1. Clone
1. cd into MakeRepo
1. Run `./MakeRepo/main.swift` for the project's root
1. Provide:
  1. A path to export the tool (Default = `/usr/local/bin/`).
  1. Your GitHub username
  1. One of your GitHub access tokens with `repo` scope
1. MakeRepo will generate an executable called `makerepo` with the given parameters and export it to the given path
1. You can then remove the cloned project
1. If the path is `/usr/local/bin/` or similar, `makerepo` can be called from any directory on command line
1. `makerepo` will ask for the repo name and then add a new repo with that name onto your GitHub profile
Big giant thanks to [John Sundell](https://github.com/JohnSundell) and [SwiftPlate](https://github.com/JohnSundell/SwiftPlate) for an extremely precious and informative example.

Enjoy!
