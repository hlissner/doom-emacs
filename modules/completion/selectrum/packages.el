;; -*- no-byte-compile: t; -*-
;;; completion/selectrum/packages.el

(package! selectrum :pin "a922b19f715ad6d046072a35a3df5ac5e4ed73d3")

(if (featurep! +prescient)
    (package! selectrum-prescient :pin "4a0f5405798cfcb98ea005078ef2e2d490e922c4")
  (package! orderless :pin "9637d7fd59f76a5b6d37470b1543ab827a0f9b8d"))

(package! consult :pin "4ca77477e980df954d75a5abde0e6584365bf404")
(when (featurep! :checkers syntax)
  (package! consult-flycheck :pin "4ca77477e980df954d75a5abde0e6584365bf404"))

(package! embark :pin "22875aa5bda21b588487b719982cbaf8410830da")
(package! embark-consult :pin "22875aa5bda21b588487b719982cbaf8410830da")

(package! marginalia :pin "624028c69b55deb3387452b9eeabe9cb963bd2a4")

(package! wgrep :pin "f9687c28bbc2e84f87a479b6ce04407bb97cfb23")
