;; -*- no-byte-compile: t; -*-
;;; completion/selectrum/packages.el

(package! selectrum :pin "8629ab5a6de572ada9dd5b18162a393969d9ebdf")

(if (featurep! +prescient)
    (package! selectrum-prescient :pin "4a0f5405798cfcb98ea005078ef2e2d490e922c4")
  (package! orderless :pin "87ab7e47e343285f7afd42779c78551332b8fd84"))

(package! consult :pin "51c1437fb555f4ff7234ed01c71e29f80138156e")
(when (featurep! :checkers syntax)
  (package! consult-flycheck :pin "51c1437fb555f4ff7234ed01c71e29f80138156e"))

(package! embark :pin "05aa11bca37db1751c86fe78f784741be5b1a066")
(package! embark-consult :pin "05aa11bca37db1751c86fe78f784741be5b1a066")

(package! marginalia :pin "ac4ab987126c0366b876e7fdcfa797822dd3580b")
