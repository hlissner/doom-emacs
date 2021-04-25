;; -*- no-byte-compile: t; -*-
;;; completion/selectrum/packages.el

(package! selectrum :pin "093f7e96a323179ee2a68a5a674e7fa2c5d721b8")

(when (featurep! +prescient)
  (package! selectrum-prescient :pin "ed2b762241bbea03e374dc9dcd4fbe207c6b2ea4"))

(when (featurep! +orderless)
  (package! orderless :pin "87ab7e47e343285f7afd42779c78551332b8fd84"))

(package! consult :pin "e04a404c8d8ca137be2b3b7cf664a11712639c31")
(when (featurep! :checkers syntax)
  (package! consult-flycheck :pin "e04a404c8d8ca137be2b3b7cf664a11712639c31"))
(when (featurep! :tools lsp)
  (package! consult-lsp :pin "ed3cfd2e67fc5117819c0c739814780bb4c2d716"))

(package! embark :pin "4d7e8e4d3be7aaff56730f76a066db2acad65371")
(package! embark-consult :pin "4d7e8e4d3be7aaff56730f76a066db2acad65371")

(package! marginalia :pin "5159256d04d123899b88ee6e7eba0c27f66d0fe2")
