;; -*- no-byte-compile: t; -*-
;;; completion/selectrum/packages.el

(package! selectrum :pin "a922b19f715ad6d046072a35a3df5ac5e4ed73d3")

(if (featurep! +prescient)
    (package! selectrum-prescient :pin "4a0f5405798cfcb98ea005078ef2e2d490e922c4")
  (package! orderless :pin "9637d7fd59f76a5b6d37470b1543ab827a0f9b8d"))

(package! consult :pin "a4b4ced2feda2153af2ba41fc6ee5453bac3d64f")
(when (featurep! :checkers syntax)
  (package! consult-flycheck :pin "44e7528d3a536755e731688c9ad9b5480b0eb880"))

(package! embark :pin "0da967adf0b1c17c59d1c0a1c166c983afe640b2")
(package! embark-consult :pin "0da967adf0b1c17c59d1c0a1c166c983afe640b2")

(package! marginalia :pin "3f33b38b7c1ecd7086942e1bd8284c54a6fd30a3")

(package! wgrep :pin "f9687c28bbc2e84f87a479b6ce04407bb97cfb23")
