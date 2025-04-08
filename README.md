# laz_hello
Nix lazarus development and build environment
Using Sample application las_hello from https://gitlab.com/freepascal.org/lazarus/lazarus/-/tree/main/examples/laz_hello


This is my personal learning journey to NixOs, jj and Pascal

## Getting Started


### Using Nix flake
```bash
# Setup development environment
$ nix develop
```

### Build application
```bash
# nix build - buildPhase does not work properly, requires manual build
$ lazbuild -B Laz_Hello.lpi
```

### Nix packaging
```bash
$ nix build
```

### Nix installation
```bash
$ nix buildprofile install .#default
```

## License

Licensed under either of

- MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)


### Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted for inclusion in the
work by you, as defined in the Apache-2.0 license, shall be dual licensed as above, without any
additional terms or conditions.

# Features

* Nix lazarus development environemnt 
* Simple graphical "hello world" application
* Nix packaging

## Backlog
* Remaning problems:
  * Fail to build using buildPhase - 
  * Nix packaging - dependencies not installed - currently assumed to be installed...
  * 

## Other references

* 