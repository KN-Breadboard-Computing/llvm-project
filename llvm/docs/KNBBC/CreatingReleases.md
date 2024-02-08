# BBCPU LLVM Releases
Here are some notes for creating a new release. This is just a guide more than anything.

## Release TODO List
When a new LLVM version is released:
1. A new branch `bbcpu/release/18.0.x` is created from `bbcpu-dev`
2. The upstream release branch is merged with newly created fork release branch
3. This merging commit is tagged 'bbcpu-llvmorg-X.Y.Z' where X.Y.Z matches that of upstream (generally it just the upstream tag with added 'bbcpu-' prefix)
4. Now is also a good time to update `bbcpu-dev` with upstream `main`

Binaries can then be built from the release tag, tested (or not) and uploaded to BB Computing's GitHub repo.
