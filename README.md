# CompatDevTools.jl

Julia compat-related development tools.

## Why was this developed?

[CompatHelper.jl](https://github.com/JuliaRegistries/CompatHelper.jl) does a great job of letting package maintainers know which compat entries should be updated to allow using the latest versions. However, managing many packages, or a package with many environments, requires keeping many compat entries up-to-date. In addition, package managers may want to keep these compat entries, between these many environments, synchronized to some extent. CompatDevTools.jl was developed to help ease this process.

## Features

The primary feature of CompatDevTools.jl is `synchronize_compats`:
```julia
    synchronize_compats(code_dir::AbstractString)

This function
 - Recursively finds all Project.toml files in `code_dir`
 - Collects the compat entries
 - Finds any inconsistent compat entries
 - Asks the user (via `REPL.TerminalMenus`) which
   version (if any) to update to, and modifies the
   Project.toml files accordingly.
```

Another simple utility function, `compat_kick_start`, was added to this package:
```julia
    compat_kick_start(code_dir::String, julia_version = "1")

Given a directory containing both a Project.toml and
Manifest.toml, print a string of a suggested compat
entry for all Project.toml dependencies.
```
This may be useful if you've started working on a new package which may have many dependencies and you need to generate your first set of compat entries. This function prints compat entries based on the existing Manifest.toml (and Project.toml) files.

## Demo

![Demo](demo.gif)
