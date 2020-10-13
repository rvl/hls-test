This is a library+exe project generated with `cabal init`.

### Test procedure

1. Ensure that you have haskell-language-server, hie-bios and ghc
   configured. I have tried:
    - ghc-8.6.5
    - ghc-8.8.4
    - haskell-language-server-0.5.0
    - ghcide-0.4.0 rev 10dbde0

   There is a `shell.nix` which contains these. Use lorri and
   emacs-direnv to integrate with emacs.

2. Verify that `cabal build all` works.

3. Set up hie.yaml link

   ```
   ln -s direct-hie.yaml
   ```

4. Open `app/Main.hs` in emacs with `lsp-haskell`. There is a
   `.dir-locals.el` file to configure the hie command.

   It will say "Could not find module MyLib" on the `import` line.

5. Open `src/MyLib.hs`.

   Once this file is loaded, the error in the other module will
   disappear.


### `hie-bios` output

See that `-isrc` is present for `app/Main.hs`.

```
rodney@blue:~/dev/test/hls-test % hie-bios debug app/Main.hs
Root directory:        /home/rodney/dev/test/hls-test
Component directory:   /home/rodney/dev/test/hls-test
GHC options:           -XOverloadedStrings -XTypeApplications -XDataKinds -fwarn-unused-binds -fwarn-unused-imports -fwarn-orphans -Wno-missing-home-modules -isrc -iapp
GHC library directory: CradleSuccess "/nix/store/vk02b66pfa4qhn7dfwwkl6s4plcywslx-ghc-8.6.5/lib/ghc-8.6.5"
GHC version:           CradleSuccess "8.6.5"
Config Location:       /home/rodney/dev/test/hls-test/hie.yaml
Cradle:                Cradle {cradleRootDir = "/home/rodney/dev/test/hls-test", cradleOptsProg = CradleAction: Direct}
Dependencies:
```


### Analysis

- [x] The `cabal-hie.yaml` configuration works correctly -- no issue
  with Cabal cradles.
- [x] `hie-bios debug app/Main.hs` reports correct ghc `-i` options.
- [x] Test latest ghcide -- same result
- [x] Test ghc8102 -- ghcide won't build
- [x] Test ghc844
