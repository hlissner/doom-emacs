;; -*- no-byte-compile: t; -*-
;;; completion/selectrum/packages.el

(package! selectrum :pin "ad9d9f02d6ac916cf4caa548c1967457bfc37c02")
(when (featurep! +prescient)
  (package! selectrum-prescient :pin "42adc802d3ba6c747bed7ea1f6e3ffbbdfc7192d"))
(when (featurep! +orderless)
  (package! orderless :pin "edce950fe1353c2284516f7b01bd37bc2d7fa136"))
(package! consult :pin "1b66afd8959f5ad3cf1ffbacae00d2bf0fe30008")
(when (featurep! :checkers syntax)
  (package! consult-flycheck :pin "1b66afd8959f5ad3cf1ffbacae00d2bf0fe30008"))
(package! embark :pin "26e73117910e78afa209524ecb8f07add45a9ec3")
(package! embark-consult :pin "26e73117910e78afa209524ecb8f07add45a9ec3")
(package! marginalia :pin "3e061a0fb5305389af5b3da17092f2f09fe92c69")
