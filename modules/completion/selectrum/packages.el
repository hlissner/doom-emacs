;; -*- no-byte-compile: t; -*-
;;; completion/selectrum/packages.el

(package! selectrum :pin "9c5f142107d28868748a5801fb53ca7c5ad75fec")
(when (featurep! +prescient)
  (package! selectrum-prescient :pin "bf0ddeb0b687e6af50ad82558bd32c17a2c0311b"))
(when (featurep! +orderless)
  (package! orderless :pin "87ab7e47e343285f7afd42779c78551332b8fd84"))
(package! consult :pin "846c715ee1df94292a9bb2467810bd7959ccf078")
(when (featurep! :checkers syntax)
  (package! consult-flycheck :pin "846c715ee1df94292a9bb2467810bd7959ccf078"))
(package! embark :pin "5f3097824f8c3d17bcd70c4e4ce597bcfcf2196f")
(package! embark-consult :pin "5f3097824f8c3d17bcd70c4e4ce597bcfcf2196f")
(package! marginalia :pin "668265af921285c726b2239dae32459bd1064d03")
