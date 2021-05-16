;; -*- no-byte-compile: t; -*-
;;; completion/selectrum/packages.el

(package! selectrum :pin "bfefb8e1a350d44b56290b2c7ddc3418ec217b30")

(if (featurep! +prescient)
    (package! selectrum-prescient :pin "4a0f5405798cfcb98ea005078ef2e2d490e922c4")
  (package! orderless :pin "d97a91f6e12ace638e65bdccefd14d1e638a2dae"))

(package! consult :pin "c839b82ce3e4db3faaecf3e9e5e2d98ad010eede")
(when (featurep! :checkers syntax)
  (package! consult-flycheck :pin "c839b82ce3e4db3faaecf3e9e5e2d98ad010eede"))

(package! embark :pin "7c850c07bfe29f3232ebb22793e8421772f820f1")
(package! embark-consult :pin "7c850c07bfe29f3232ebb22793e8421772f820f1")

(package! marginalia :pin "445d2832a2f06484ad28d9b55676c52d63cd0a46")

(package! wgrep :pin "f9687c28bbc2e84f87a479b6ce04407bb97cfb23")
