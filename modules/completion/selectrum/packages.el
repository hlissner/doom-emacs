;; -*- no-byte-compile: t; -*-
;;; completion/selectrum/packages.el

(if (featurep! +vertico)
    (package! vertico
      :recipe (:host github :repo "minad/vertico")
      :pin "c9157759a015ac32cb299c18c84c6d5fb34e0aa1")
  (package! selectrum :pin "a19bbe94de492bf504399c093cfc5695eb630fa8"))

(if (featurep! +prescient)
    (package! selectrum-prescient :pin "4a0f5405798cfcb98ea005078ef2e2d490e922c4")
  (package! orderless :pin "2646dad28c0819fbe9ee521d39efb9ae40e03982"))

(package! consult :pin "f1ae2244da20702525fe2991076322b9c6b34202")
(when (featurep! :checkers syntax)
  (package! consult-flycheck :pin "92b259e6a8ebe6439f67d3d7ffa44b7e64b76478"))

(package! embark :pin "acbe1cba548832d295449da348719f69b9685c6f")
(package! embark-consult :pin "acbe1cba548832d295449da348719f69b9685c6f")

(package! marginalia :pin "e31e03c5857bf7aada333f693caedfc3087d6297")

(package! wgrep :pin "f9687c28bbc2e84f87a479b6ce04407bb97cfb23")
