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
(defun +selectrum/embark-wgrep ()
  "Invoke a wgrep buffer on the current selectrum results, if supported."
  (interactive)
  (require 'wgrep)
  (pcase-let ((`(,type . ,candidates)
               (run-hook-with-args-until-success 'embark-candidate-collectors)))
    (if (null candidates)
        (user-error "No candidates for export")
      (if (eq type 'consult-grep)
          (embark--quit-and-run
           (lambda ()
             (let ((buf (generate-new-buffer "*Embark Export Wgrep*")))
               (with-current-buffer buf
                 (insert (propertize "Exported grep results:\n\n" 'wgrep-header t))
                 (dolist (line candidates) (insert line "\n"))
                 (goto-char (point-min))
                 (grep-mode)
                 (setq-local wgrep-header/footer-parser #'ignore)
                 (wgrep-setup))
               (pop-to-buffer buf)
               (wgrep-change-to-wgrep-mode))))
        (user-error "embark category %S doesn't support wgrep" type)))))
