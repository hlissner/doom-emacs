;; -*- no-byte-compile: t; -*-
;;; completion/selectrum/packages.el

(package! selectrum :pin "a922b19f715ad6d046072a35a3df5ac5e4ed73d3")

(if (featurep! +prescient)
    (package! selectrum-prescient :pin "4a0f5405798cfcb98ea005078ef2e2d490e922c4")
  (package! orderless :pin "9637d7fd59f76a5b6d37470b1543ab827a0f9b8d"))

(package! consult :pin "556ff4eb31eb1d00a2afdda6664d03b698264e3c")
(when (featurep! :checkers syntax)
  (package! consult-flycheck :pin "556ff4eb31eb1d00a2afdda6664d03b698264e3c"))

(package! embark :pin "a21e510bc63c8ddc98b2bb3e6fff38e9d7f41ca9")
(package! embark-consult :pin "a21e510bc63c8ddc98b2bb3e6fff38e9d7f41ca9")

(package! marginalia :pin "624028c69b55deb3387452b9eeabe9cb963bd2a4")

(package! wgrep :pin "f9687c28bbc2e84f87a479b6ce04407bb97cfb23")
