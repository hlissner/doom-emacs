;; -*- no-byte-compile: t; -*-
;;; completion/vertico/packages.el

(package! vertico
  :recipe (:host github :repo "minad/vertico"
           :files ("*.el" "extensions/*.el"))
  :pin "9f6cd5d431ec6d288676af80e932d928346a1b36")

(package! orderless :pin "2646dad28c0819fbe9ee521d39efb9ae40e03982")

(package! consult :pin "f17db9520ddd612dc837f4112b6bcbb172acef85")
(when (featurep! :checkers syntax)
  (package! consult-flycheck :pin "92b259e6a8ebe6439f67d3d7ffa44b7e64b76478"))

(package! embark :pin "acbe1cba548832d295449da348719f69b9685c6f")
(package! embark-consult :pin "acbe1cba548832d295449da348719f69b9685c6f")

(package! marginalia :pin "3bf0a4db55f6267467f0a08715f4776509a3b503")

(package! wgrep :pin "f9687c28bbc2e84f87a479b6ce04407bb97cfb23")

(when (featurep! +icons)
  (package! all-the-icons-completion
    :recipe (:host github :repo "iyefrat/all-the-icons-completion")
    :pin "975345f1b618fd316729c3cae6d11b96db530fd4"))
