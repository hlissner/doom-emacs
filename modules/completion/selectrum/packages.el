;; -*- no-byte-compile: t; -*-
;;; completion/selectrum/packages.el

(package! selectrum :pin "909f614319dad6c7eeebb76b2c2501e8215718ea")

(if (featurep! +prescient)
    (package! selectrum-prescient :pin "4a0f5405798cfcb98ea005078ef2e2d490e922c4")
  (package! orderless :pin "9637d7fd59f76a5b6d37470b1543ab827a0f9b8d"))

(package! consult :pin "a7964f622e0f695f55ce86092a627a1a9d57caf5")
(when (featurep! :checkers syntax)
  (package! consult-flycheck :pin "a7964f622e0f695f55ce86092a627a1a9d57caf5"))

(package! embark :pin "0086413ef295025bde774157763e00746ee8fbf6")
(package! embark-consult :pin "0086413ef295025bde774157763e00746ee8fbf6")

(package! marginalia :pin "624028c69b55deb3387452b9eeabe9cb963bd2a4")

(package! wgrep :pin "f9687c28bbc2e84f87a479b6ce04407bb97cfb23")
