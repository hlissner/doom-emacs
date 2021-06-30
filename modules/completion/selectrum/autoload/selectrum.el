;;; completion/selectrum/autoload/selectrum.el -*- lexical-binding: t; -*-

;;;###autoload
(defadvice! +selectrum-orderless-match-with-one-face (fn &rest args)
  "Function to help company to highlight all candidates with just
one face."
  :around 'company-capf--candidates
  (let ((orderless-match-faces [completions-common-part]))
    (apply fn args)))

;;;###autoload
(cl-defun +selectrum-file-search (&key query in all-files (recursive t) prompt args)
  "Conduct a file search using ripgrep.

:query STRING
  Determines the initial input to search for.
:in PATH
  Sets what directory to base the search out of. Defaults to the current project's root.
:recursive BOOL
  Whether or not to search files recursively from the base directory."
  (declare (indent defun))
  (unless (executable-find "rg")
    (user-error "Couldn't find ripgrep in your PATH"))
  (require 'consult)
  (setq deactivate-mark t)
  (let* ((project-root (or (doom-project-root) default-directory))
         (directory (or in project-root))
         (args (split-string
                (string-trim
                 (concat (if all-files "-uu")
                         (unless recursive "--maxdepth 1")
                         "--null --line-buffered --color=always --max-columns=500 --no-heading --line-number"
                         " --hidden -g !.git "
                         (mapconcat #'shell-quote-argument args " ")))
                " "))
         (prompt (or prompt
                     (format "rg [%s]: "
                             (cond ((equal directory default-directory)
                                    "./")
                                   ((equal directory project-root)
                                    (projectile-project-name))
                                   ((file-relative-name directory project-root))))))
         (query (or query
                    (when (doom-region-active-p)
                      (replace-regexp-in-string
                       "[! |]" (lambda (substr)
                                 (cond ((and (string= substr " ")
                                             (not (featurep! +fuzzy)))
                                        "  ")
                                       ((string= substr "|")
                                        "\\\\\\\\|")
                                       ((concat "\\\\" substr))))
                       (rxt-quote-pcre (doom-thing-at-point-or-region))))))
         (ripgrep-command (mapconcat #'identity `("rg" ,@args "." "-e ARG OPTS" ) " ")))
    (consult--grep prompt ripgrep-command directory query)))

;;;###autoload
(defun +selectrum/project-search (&optional arg initial-query directory)
  "Peforms a live project search from the project root using ripgrep.
If ARG (universal argument), include all files, even hidden or compressed ones,
in the search."
  (interactive "P")
  (+selectrum-file-search :query initial-query :in directory :all-files arg))

;;;###autoload
(defun +selectrum/project-search-from-cwd (&optional arg initial-query)
  "Performs a live project search from the current directory.
If ARG (universal argument), include all files, even hidden or compressed ones."
  (interactive "P")
  (+selectrum/project-search arg initial-query default-directory))

;;;###autoload
(defun +selectrum/search-symbol-at-point ()
  (interactive)
  (consult-line (thing-at-point 'symbol)))

;;;###autoload
(defun +selectrum/backward-updir ()
  "Delete char before or go up directory for file cagetory selectrum buffers."
  (interactive)
  (let ((metadata (completion-metadata (minibuffer-contents)
                                       minibuffer-completion-table
                                       minibuffer-completion-predicate)))
    (if (and (eq (char-before) ?/)
             (eq (completion-metadata-get metadata 'category) 'file))
        (let ((new-path (minibuffer-contents)))
          (delete-region (minibuffer-prompt-end) (point-max))
          (insert (abbreviate-file-name
                   (file-name-directory
                    (directory-file-name
                     (expand-file-name new-path))))))
      (call-interactively 'backward-delete-char))))


;;;###autoload
(defun +selectrum/embark-export-write ()
  "Export the current selectrum results to a writable buffer if possible.

Supports exporting consult-grep to wgrep, file to wdeired, and consult-location to occur-edit"
  (interactive)
  (require 'wgrep)
  (pcase-let ((`(,type . ,candidates)
               (run-hook-with-args-until-success 'embark-candidate-collectors)))
    (pcase type
      ('consult-grep (let ((embark-after-export-hook #'wgrep-change-to-wgrep-mode))
                       (embark-export)))
      ('file (let ((embark-after-export-hook #'wdired-change-to-wdired-mode))
               (embark-export)))
      ('consult-location (let ((embark-after-export-hook #'occur-edit-mode))
                           (embark-export)))
      (x (user-error "embark category %S doesn't support writable export" x)))))

;;;###autoload
(defun +selectrum/embark-preview ()
  "Previews candidate in selectrum buffer, unless it's a consult command"
  (interactive)
  (unless (bound-and-true-p consult--preview-function)
    (save-selected-window
      (let ((embark-quit-after-action nil))
        (embark-default-action)))))

;;;###autoload
(defun +selectrum/next-candidate-preview ()
  "Move to next candidate and preivew it"
  (interactive)
  (if (featurep! :completion selectrum +vertico)
      (vertico-next)
    (selectrum-next-candidate))
  (+selectrum/embark-preview))

;;;###autoload
(defun +selectrum/previous-candidate-preview ()
  "Move to previous candidate and preview it"
  (interactive)
  (if (featurep! :completion selectrum +vertico)
      (vertico-previous)
    (selectrum-previous-candidate))
  (+selectrum/embark-preview))

;;;###autoload
(defun +selectrum/repeat ()
  "Repeat the last selectrum/vertico command."
  (interactive)
  (if (featurep! :completion selectrum +vertico)
      (user-error "The vertico flag doesn't support repeating commands (yet)")
    (selectrum-repeat)))
