;; -*- no-byte-compile: t; -*-
;;; ui/modeline/packages.el

(unless (featurep! +light)
  (package! doom-modeline :pin "06606e0b8b3c19fbe56e25702e2a664deec593c3"))
(package! anzu :pin "bdb3da5028935a4aea55c40769bc191a81afb54e")
(when (featurep! :editor evil)
  (package! evil-anzu :pin "d3f6ed4773b48767bd5f4708c7f083336a8a8a86"))
(when (featurep! +keycast)
  (package! keycast :pin "038475c178e90c7bad64d113db26d42cad60e149"))
