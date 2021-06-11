;; -*- no-byte-compile: t; -*-
;;; ui/dired-sidebar/packages.el

(unless (featurep! :emacs dired +ranger)
  (package! dired-sidebar :pin "da77919081d9a4e73c2df63542353319381e4f89"))
(unless (featurep! :emacs dired +ranger)
  (package! dired-subtree :pin "f49a8bbf95f70671a74a24f7f4de453b2686be46"))
