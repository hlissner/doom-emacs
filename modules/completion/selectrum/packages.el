;; -*- no-byte-compile: t; -*-
;;; completion/selectrum/packages.el

(package! selectrum :pin "52b112954958808b064cb141b40ee9a48d14226b")
(when (featurep! +prescient)
  (package! selectrum-prescient :pin "8573df977eaceffc6607b7242ff8c0dab02aad65"))
(when (featurep! +orderless)
  (package! orderless :pin "44935d8962be5724d8a3a4358ce0a4222450ee26"))
(package! consult :pin "63f0a893b5502c938eec87b778feb3edd380546d")
(when (featurep! :checkers syntax)
  (package! consult-flycheck :pin "63f0a893b5502c938eec87b778feb3edd380546d"))
(package! embark :pin "33e9af8403b22f75c01db96f39aee344de6ffaa8")
(package! embark-consult :pin "33e9af8403b22f75c01db96f39aee344de6ffaa8")
(package! marginalia :pin "f26374545275cdde96d67576a43f3a919b6927cd")
