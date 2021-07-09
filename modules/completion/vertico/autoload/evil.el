;; completion/vertico/autoload/evil.el -*- lexical-binding: t; -*-
;;;###if (featurep! :editor evil)

;;;###autoload (autoload '+vertico:project-search "completion/vertico/autoload/evil" nil t)
(evil-define-command +vertico:project-search (query &optional all-files-p)
  "Ex interface for `+vertico/project-search'."
  (interactive "<a><!>")
  (+vertico/project-search all-files-p query))

;;;###autoload (autoload '+vertico:project-search-from-cwd "completion/vertico/autoload/evil" nil t)
(evil-define-command +vertico:project-search-from-cwd (query &optional recurse-p)
  "Ex interface for `+vertico/project-search-from-cwd'."
  (interactive "<a><!>")
  (+vertico/project-search-from-cwd (not recurse-p) query))
