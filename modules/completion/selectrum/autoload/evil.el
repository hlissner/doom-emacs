;; completion/selectrum/autoload/evil.el -*- lexical-binding: t; -*-
;;;###if (featurep! :editor evil)

;;;###autoload (autoload '+selectrum:project-search "completion/ivy/autoload/evil" nil t)
(evil-define-command +selectrum:project-search (query &optional all-files-p)
  "Ex interface for `+selectrum/project-search'."
  (interactive "<a><!>")
  (+selectrum/project-search all-files-p query))

;;;###autoload (autoload '+selectrum:project-search-from-cwd "completion/ivy/autoload/evil" nil t)
(evil-define-command +selectrum:project-search-from-cwd (query &optional recurse-p)
  "Ex interface for `+selectrum/project-search-from-cwd'."
  (interactive "<a><!>")
  (+selectrum/project-search-from-cwd (not recurse-p) query))
