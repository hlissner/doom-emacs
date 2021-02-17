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
(defadvice! +default/extended-yank-pop (&rest _)
  "Interactively select what text to insert from the kill ring."
  :override '+default/yank-pop
  (interactive "P")
  (call-interactively
   (cond ((fboundp 'counsel-yank-pop)    #'counsel-yank-pop)
         ((fboundp 'consult-yank-pop)    #'consult-yank-pop)
         ((fboundp 'helm-show-kill-ring) #'helm-show-kill-ring)
         ((error "No kill-ring search backend available. Enable ivy or helm!")))))

;;;###autoload
(defadvice! +default/extended-search-project (&optional arg)
  "Conduct a text search in the current project root.
If prefix ARG is set, include ignored/hidden files."
  :override '+default/search-project
  (interactive "P")
  (let* ((projectile-project-root nil)
         (disabled-command-function nil)
         (current-prefix-arg (unless (eq arg 'other) arg))
         (default-directory
           (if (eq arg 'other)
               (if-let (projects (projectile-relevant-known-projects))
                   (completing-read "Search project: " projects nil t)
                 (user-error "There are no known projects"))
             default-directory)))
    (call-interactively
     (cond ((featurep! :completion ivy)  #'+ivy/project-search)
           ((featurep! :completion helm) #'+helm/project-search)
           ((fboundp 'consult--grep)     #'+selectrum/project-search)
           (#'projectile-ripgrep)))))

;;;###autoload
(defadvice! +default/extended-search-cwd (&optional arg)
  "Conduct a text search in files under the current folder.
If prefix ARG is set, prompt for a directory to search from."
  :override '+default/search-cwd
  (interactive "P")
  (let ((default-directory
          (if arg
              (read-directory-name "Search directory: ")
            default-directory)))
    (call-interactively
     (cond ((featurep! :completion ivy)  #'+ivy/project-search-from-cwd)
           ((featurep! :completion helm) #'+helm/project-search-from-cwd)
           ((fboundp 'consult--grep) #'+selectrum/project-search-from-cwd)
           (#'rgrep)))))

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
         (ripgrep-command (format "rg %s . -e"
                                  (string-trim
                                   (concat (if all-files "-uu")
                                           (unless recursive "--maxdepth 1")
                                           "--null --line-buffered --color=always --max-columns=500 --no-heading --line-number"
                                           " --hidden -g!.git "
                                           (mapconcat #'shell-quote-argument args " ")))
                                  args)))
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