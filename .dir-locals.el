((haskell-mode . ((compile-command . "cabal v2-build all")
                  (haskell-process-type . ghci)
                  ; (lsp-haskell-process-path-hie . "haskell-language-server")
                  (lsp-haskell-process-path-hie . "ghcide")
                  (lsp-enable-file-watchers . t))))
