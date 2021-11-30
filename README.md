# BCWally

Thin Swift wrapper around [LibWally](https://github.com/ElementsProject/libwally-core), a collection of useful primitives for cryptocurrency wallets.

This is a fork of [LibWally Swift](https://github.com/blockchain/libwally-swift). It has a new build system for building a universal XCFramework for use with MacOSX, Mac Catalyst, iOS devices, and the iOS simulator across Intel and Apple Silicon (ARM).

For higher-level functions and more, see [BCFoundation](https://github.com/BlockchainCommons/BCFoundation).

## Dependencies

```sh
$ brew install autoconf autogen gsed
```

## Build

```sh
$ git clone https://github.com/blockchaincommons/BCWally.git
$ cd BCWally
$ ./build.sh
```

The resulting framework is `build/BCWally.xcframework`. Add to your project.
