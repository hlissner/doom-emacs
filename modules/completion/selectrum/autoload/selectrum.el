;;; completion/selectrum/autoload/selectrum.el -*- lexical-binding: t; -*-

;;;###autoload
(defadvice! +orderless-match-with-one-face (fn &rest args)
    "Function to help company to highlight all candidates with just
one face."
    :around 'company-capf--candidates
    (let ((orderless-match-faces [completions-common-part]))
        (apply fn args)))

;;;###autoload
(defun +embark-which-key-action-indicator (map)
  "Helper function to display the `whichey' help buffer for embark."
  (which-key--show-keymap "Embark" map nil nil 'no-paging)
  #'which-key--hide-popup-ignore-command)

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
  (let* ((this-command 'consult--grep)
         (project-root (or (doom-project-root) default-directory))
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
(defun +consult-line-symbol-at-point ()
  (interactive)
  (consult-line (thing-at-point 'symbol)))
