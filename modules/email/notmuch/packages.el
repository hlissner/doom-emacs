;; -*- no-byte-compile: t; -*-
;;; email/notmuch/packages.el

(package! notmuch :pin "63413a5563450bdedee4c077f2f998578e75083a")
(when (featurep! +org)
  (package! org-mime :pin "eb21c02ba8f97fe69c14dc657a7883b982664649"))
(when (featurep! :completion ivy)
  (package! counsel-notmuch :pin "a4a1562935e4180c42524c51609d1283e9be0688"))
(when (featurep! :completion helm)
  (package! helm-notmuch :pin "97a01497e079a7b6505987e9feba6b603bbec288"))
(when (featurep! :completion vertico)
  (package! consult-notmuch :pin "67cf219fcce211237347a783ce6982402341d5fd"))
