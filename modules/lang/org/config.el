;;; lang/org/config.el -*- lexical-binding: t; -*-

(defvar +org-babel-mode-alist
  '((c . C)
    (cpp . C)
    (C++ . C)
    (D . C)
    (elisp . emacs-lisp)
    (sh . shell)
    (bash . shell)
    (matlab . octave)
    (rust . rustic-babel)
    (amm . ammonite))
  "An alist mapping languages to babel libraries. This is necessary for babel
libraries (ob-*.el) that don't match the name of the language.

For example, (fish . shell) will cause #+BEGIN_SRC fish blocks to load
ob-shell.el when executed.")

(defvar +org-babel-load-functions ()
  "A list of functions executed to load the current executing src block. They
take one argument (the language specified in the src block, as a string). Stops
at the first function to return non-nil.")

(defvar +org-capture-todo-file "todo.org"
  "Default target for todo entries.

Is relative to `org-directory', unless it is absolute. Is used in Doom's default
`org-capture-templates'.")

(defvar +org-capture-changelog-file "changelog.org"
  "Default target for changelog entries.

Is relative to `org-directory' unless it is absolute. Is used in Doom's default
`org-capture-templates'.")

(defvar +org-capture-notes-file "notes.org"
  "Default target for storing notes.

Used as a fall back file for org-capture.el, for templates that do not specify a
target file.

Is relative to `org-directory', unless it is absolute. Is used in Doom's default
`org-capture-templates'.")

(defvar +org-capture-journal-file "journal.org"
  "Default target for storing timestamped journal entries.

Is relative to `org-directory', unless it is absolute. Is used in Doom's default
`org-capture-templates'.")

(defvar +org-capture-projects-file "projects.org"
  "Default, centralized target for org-capture templates.")

(defvar +org-habit-graph-padding 2
  "The padding added to the end of the consistency graph")

(defvar +org-habit-min-width 30
  "Hides the consistency graph if the `org-habit-graph-column' is less than this value")

(defvar +org-habit-graph-window-ratio 0.3
  "The ratio of the consistency graphs relative to the window width")


;;
;;; `org-load' hooks

(defun +org-init-org-directory-h ()
  (unless org-directory
    (setq-default org-directory "~/org"))
  (unless org-id-locations-file
    (setq org-id-locations-file (expand-file-name ".orgids" org-directory))))


(defun +org-init-agenda-h ()
  (unless org-agenda-files
    (setq-default org-agenda-files (list org-directory)))
  (setq-default
   ;; Different colors for different priority levels
   org-agenda-deadline-faces
   '((1.001 . error)
     (1.0 . org-warning)
     (0.5 . org-upcoming-deadline)
     (0.0 . org-upcoming-distant-deadline))
   ;; Don't monopolize the whole frame just for the agenda
   org-agenda-window-setup 'current-window
   org-agenda-skip-unavailable-files t
   ;; Shift the agenda to show the previous 3 days and the next 7 days for
   ;; better context on your week. The past is less important than the future.
   org-agenda-span 10
   org-agenda-start-on-weekday nil
   org-agenda-start-day "-3d"
   ;; Optimize `org-agenda' by inhibiting extra work while opening agenda
   ;; buffers in the background. They'll be "restarted" if the user switches to
   ;; them anyway (see `+org-exclude-agenda-buffers-from-workspace-h')
   org-agenda-inhibit-startup t))


(defun +org-init-appearance-h ()
  "Configures the UI for `org-mode'."
  (setq org-indirect-buffer-display 'current-window
        org-eldoc-breadcrumb-separator " → "
        org-enforce-todo-dependencies t
        org-entities-user
        '(("flat"  "\\flat" nil "" "" "266D" "♭")
          ("sharp" "\\sharp" nil "" "" "266F" "♯"))
        org-fontify-done-headline t
        org-fontify-quote-and-verse-blocks t
        org-fontify-whole-heading-line t
        org-hide-leading-stars t
        org-image-actual-width nil
        org-imenu-depth 8
        ;; Sub-lists should have different bullets
        org-list-demote-modify-bullet '(("+" . "-") ("-" . "+") ("*" . "+") ("1." . "a."))
        org-priority-faces
        '((?A . error)
          (?B . warning)
          (?C . success))
        org-startup-indented t
        org-tags-column 0
        org-use-sub-superscripts '{})

  (setq org-refile-targets
        '((nil :maxlevel . 3)
          (org-agenda-files :maxlevel . 3))
        ;; Without this, completers like ivy/helm are only given the first level of
        ;; each outline candidates. i.e. all the candidates under the "Tasks" heading
        ;; are just "Tasks/". This is unhelpful. We want the full path to each refile
        ;; target! e.g. FILE/Tasks/heading/subheading
        org-refile-use-outline-path 'file
        org-outline-path-complete-in-steps nil)

  (plist-put org-format-latex-options :scale 1.5) ; larger previews

  ;; HACK Face specs fed directly to `org-todo-keyword-faces' don't respect
  ;;      underlying faces like the `org-todo' face does, so we define our own
  ;;      intermediary faces that extend from org-todo.
  (with-no-warnings
    (custom-declare-face '+org-todo-active  '((t (:inherit (bold font-lock-constant-face org-todo)))) "")
    (custom-declare-face '+org-todo-project '((t (:inherit (bold font-lock-doc-face org-todo)))) "")
    (custom-declare-face '+org-todo-onhold  '((t (:inherit (bold warning org-todo)))) "")
    (custom-declare-face '+org-todo-cancel  '((t (:inherit (bold error org-todo)))) ""))
  (setq org-todo-keywords
        '((sequence
           "TODO(t)"  ; A task that needs doing & is ready to do
           "PROJ(p)"  ; A project, which usually contains other tasks
           "LOOP(r)"  ; A recurring task
           "STRT(s)"  ; A task that is in progress
           "WAIT(w)"  ; Something external is holding up this task
           "HOLD(h)"  ; This task is paused/on hold because of me
           "IDEA(i)"  ; An unconfirmed and unapproved task or notion
           "|"
           "DONE(d)"  ; Task successfully completed
           "KILL(k)") ; Task was cancelled, aborted or is no longer applicable
          (sequence
           "[ ](T)"   ; A task that needs doing
           "[-](S)"   ; Task is in progress
           "[?](W)"   ; Task is being held up or paused
           "|"
           "[X](D)")  ; Task was completed
          (sequence
           "|"
           "OKAY(o)"
           "YES(y)"
           "NO(n)"))
        org-todo-keyword-faces
        '(("[-]"  . +org-todo-active)
          ("STRT" . +org-todo-active)
          ("[?]"  . +org-todo-onhold)
          ("WAIT" . +org-todo-onhold)
          ("HOLD" . +org-todo-onhold)
          ("PROJ" . +org-todo-project)
          ("NO"   . +org-todo-cancel)
          ("KILL" . +org-todo-cancel)))

  (defadvice! +org-display-link-in-eldoc-a (&rest _)
    "Display full link in minibuffer when cursor/mouse is over it."
    :before-until #'org-eldoc-documentation-function
    (when-let (link (org-element-property :raw-link (org-element-context)))
      (format "Link: %s" link)))

  ;; Automatic indent detection in org files is meaningless
  (add-to-list 'doom-detect-indentation-excluded-modes 'org-mode)

  (set-ligatures! 'org-mode
    :name "#+NAME:"
    :name "#+name:"
    :src_block "#+BEGIN_SRC"
    :src_block "#+begin_src"
    :src_block_end "#+END_SRC"
    :src_block_end "#+end_src"
    :quote "#+BEGIN_QUOTE"
    :quote "#+begin_quote"
    :quote_end "#+END_QUOTE"
    :quote_end "#+end_quote"))


(defun +org-init-babel-h ()
  (setq org-src-preserve-indentation t  ; use native major-mode indentation
        org-src-tab-acts-natively t     ; we do this ourselves
        ;; You don't need my permission (just be careful, mkay?)
        org-confirm-babel-evaluate nil
        org-link-elisp-confirm-function nil
        ;; Show src buffer in popup, and don't monopolize the frame
        org-src-window-setup 'other-window
        ;; Our :lang common-lisp module uses sly, so...
        org-babel-lisp-eval-fn #'sly-eval)

  ;; I prefer C-c C-c over C-c ' (more consistent)
  (define-key org-src-mode-map (kbd "C-c C-c") #'org-edit-src-exit)

  ;; Don't process babel results asynchronously when exporting org, as they
  ;; won't likely complete in time, and will instead output an ob-async hash
  ;; instead of the wanted evaluation results.
  (after! ob
    (add-to-list 'org-babel-default-lob-header-args '(:sync)))

  (defadvice! +org-babel-disable-async-if-needed-a (orig-fn &optional fn arg info params)
    "Disable ob-async when leaving it on would cause errors or issues.

Such as when exporting org documents or executing babel blocks with :session
parameters (which ob-async does not support), in which case this advice forces
these blocks to run synchronously.

Also adds support for a `:sync' parameter to override `:async'."
    :around #'ob-async-org-babel-execute-src-block
    (if (null fn)
        (funcall orig-fn fn arg info params)
      (let* ((info (or info (org-babel-get-src-block-info)))
             (params (org-babel-merge-params (nth 2 info) params)))
        (cond ((or (assq :sync params)
                   (not (assq :async params))
                   (member (car info) ob-async-no-async-languages-alist))
               (funcall fn arg info params))
              ((not (member (cdr (assq :session params)) '("none" nil)))
               (message "Org babel :: :session is incompatible with :async. Executing synchronously!")
               nil)
              ((funcall orig-fn fn arg info params))))))

  (defadvice! +org-fix-newline-and-indent-in-src-blocks-a (&optional indent _arg _interactive)
    "Mimic `newline-and-indent' in src blocks w/ lang-appropriate indentation."
    :after #'org-return
    (when (and indent
               org-src-tab-acts-natively
               (org-in-src-block-p t))
      (org-babel-do-in-edit-buffer
       (call-interactively #'indent-for-tab-command))))

  (defadvice! +org-inhibit-mode-hooks-a (orig-fn datum name &optional initialize &rest args)
    "Prevent potentially expensive mode hooks in `org-babel-do-in-edit-buffer' ops."
    :around #'org-src--edit-element
    (apply orig-fn datum name
           (if (and (eq org-src-window-setup 'switch-invisibly)
                    (functionp initialize))
               ;; org-babel-do-in-edit-buffer is used to execute quick, one-off
               ;; logic in the context of another major mode, but initializing a
               ;; major mode with expensive hooks can be terribly expensive.
               ;; Since Doom adds its most expensive hooks to
               ;; MAJOR-MODE-local-vars-hook, we can savely inhibit those.
               (lambda ()
                 (let ((doom-inhibit-local-var-hooks t))
                   (funcall initialize)))
             initialize)
           args))

  ;; Refresh inline images after executing src blocks (useful for plantuml or
  ;; ipython, where the result could be an image)
  (add-hook 'org-babel-after-execute-hook #'org-redisplay-inline-images)

  (after! python
    (setq org-babel-python-command python-shell-interpreter))

  (after! ob-ditaa
    ;; TODO Should be fixed upstream
    (let ((default-directory (org-find-library-dir "org-contribdir")))
      (setq org-ditaa-jar-path     (expand-file-name "scripts/ditaa.jar")
            org-ditaa-eps-jar-path (expand-file-name "scripts/DitaaEps.jar")))))


(defun +org-init-babel-lazy-loader-h ()
  "Load babel libraries lazily when babel blocks are executed."
  (defun +org--babel-lazy-load (lang &optional async)
    (cl-check-type lang (or symbol null))
    (unless (cdr (assq lang org-babel-load-languages))
      (when async
        ;; ob-async has its own agenda for lazy loading packages (in the child
        ;; process), so we only need to make sure it's loaded.
        (require 'ob-async nil t))
      (prog1 (or (run-hook-with-args-until-success '+org-babel-load-functions lang)
                 (require (intern (format "ob-%s" lang)) nil t)
                 (require lang nil t))
        (add-to-list 'org-babel-load-languages (cons lang t)))))

  (defadvice! +org--export-lazy-load-library-h ()
    "Lazy load a babel package when a block is executed during exporting."
    :before #'org-babel-exp-src-block
    (+org--babel-lazy-load-library-a (org-babel-get-src-block-info)))

  (defadvice! +org--src-lazy-load-library-a (lang)
    "Lazy load a babel package to ensure syntax highlighting."
    :before #'org-src--get-lang-mode
    (or (cdr (assoc lang org-src-lang-modes))
        (+org--babel-lazy-load lang)))

  ;; This also works for tangling
  (defadvice! +org--babel-lazy-load-library-a (info)
    "Load babel libraries lazily when babel blocks are executed."
    :after-while #'org-babel-confirm-evaluate
    (let* ((lang (nth 0 info))
           (lang (cond ((symbolp lang) lang)
                       ((stringp lang) (intern lang))))
           (lang (or (cdr (assq lang +org-babel-mode-alist))
                     lang)))
      (+org--babel-lazy-load
       lang (and (not (assq :sync (nth 2 info)))
                 (assq :async (nth 2 info))))
      t))

  (advice-add #'org-babel-do-load-languages :override #'ignore))


(defun +org-init-capture-defaults-h ()
  "Sets up some reasonable defaults, as well as two `org-capture' workflows that
I like:

1. The traditional way: invoking `org-capture' directly, via SPC X, or through
   the :cap ex command.
2. Through a org-capture popup frame that is invoked from outside Emacs (the
   ~/.emacs.d/bin/org-capture script). This can be invoked from qutebrowser,
   vimperator, dmenu or a global keybinding."
  (setq org-default-notes-file
        (expand-file-name +org-capture-notes-file org-directory)
        +org-capture-journal-file
        (expand-file-name +org-capture-journal-file org-directory)
        org-capture-templates
        '(("t" "Personal todo" entry
           (file+headline +org-capture-todo-file "Inbox")
           "* [ ] %?\n%i\n%a" :prepend t)
          ("n" "Personal notes" entry
           (file+headline +org-capture-notes-file "Inbox")
           "* %u %?\n%i\n%a" :prepend t)
          ("j" "Journal" entry
           (file+olp+datetree +org-capture-journal-file)
           "* %U %?\n%i\n%a" :prepend t)

          ;; Will use {project-root}/{todo,notes,changelog}.org, unless a
          ;; {todo,notes,changelog}.org file is found in a parent directory.
          ;; Uses the basename from `+org-capture-todo-file',
          ;; `+org-capture-changelog-file' and `+org-capture-notes-file'.
          ("p" "Templates for projects")
          ("pt" "Project-local todo" entry  ; {project-root}/todo.org
           (file+headline +org-capture-project-todo-file "Inbox")
           "* TODO %?\n%i\n%a" :prepend t)
          ("pn" "Project-local notes" entry  ; {project-root}/notes.org
           (file+headline +org-capture-project-notes-file "Inbox")
           "* %U %?\n%i\n%a" :prepend t)
          ("pc" "Project-local changelog" entry  ; {project-root}/changelog.org
           (file+headline +org-capture-project-changelog-file "Unreleased")
           "* %U %?\n%i\n%a" :prepend t)

          ;; Will use {org-directory}/{+org-capture-projects-file} and store
          ;; these under {ProjectName}/{Tasks,Notes,Changelog} headings. They
          ;; support `:parents' to specify what headings to put them under, e.g.
          ;; :parents ("Projects")
          ("o" "Centralized templates for projects")
          ("ot" "Project todo" entry
           (function +org-capture-central-project-todo-file)
           "* TODO %?\n %i\n %a"
           :heading "Tasks"
           :prepend nil)
          ("on" "Project notes" entry
           (function +org-capture-central-project-notes-file)
           "* %U %?\n %i\n %a"
           :heading "Notes"
           :prepend t)
          ("oc" "Project changelog" entry
           (function +org-capture-central-project-changelog-file)
           "* %U %?\n %i\n %a"
           :heading "Changelog"
           :prepend t)))

  ;; Kill capture buffers by default (unless they've been visited)
  (after! org-capture
    (org-capture-put :kill-buffer t))

  ;; Fix #462: when refiling from org-capture, Emacs prompts to kill the
  ;; underlying, modified buffer. This fixes that.
  (add-hook 'org-after-refile-insert-hook #'save-buffer)

  ;; HACK Doom doesn't support `customize'. Best not to advertise it as an
  ;;      option in `org-capture's menu.
  (defadvice! +org--remove-customize-option-a (orig-fn table title &optional prompt specials)
    :around #'org-mks
    (funcall orig-fn table title prompt
             (remove '("C" "Customize org-capture-templates")
                     specials)))

  (defadvice! +org--capture-expand-variable-file-a (file)
    "If a variable is used for a file path in `org-capture-template', it is used
as is, and expanded relative to `default-directory'. This changes it to be
relative to `org-directory', unless it is an absolute path."
    :filter-args #'org-capture-expand-file
    (if (and (symbolp file) (boundp file))
        (expand-file-name (symbol-value file) org-directory)
      file))

  (add-hook! 'org-capture-mode-hook
    (defun +org-show-target-in-capture-header-h ()
      (setq header-line-format
            (format "%s%s%s"
                    (propertize (abbreviate-file-name (buffer-file-name (buffer-base-buffer)))
                                'face 'font-lock-string-face)
                    org-eldoc-breadcrumb-separator
                    header-line-format)))))


(defun +org-init-capture-frame-h ()
  (add-hook 'org-capture-after-finalize-hook #'+org-capture-cleanup-frame-h)

  (defadvice! +org-capture-refile-cleanup-frame-a (&rest _)
    :after #'org-capture-refile
    (+org-capture-cleanup-frame-h))

  (when (featurep! :ui doom-dashboard)
    (add-hook '+doom-dashboard-inhibit-functions #'+org-capture-frame-p)))


(defun +org-init-attachments-h ()
  "Sets up org's attachment system."
  (setq org-attach-store-link-p t     ; store link after attaching files
        org-attach-use-inheritance t) ; inherit properties from parent nodes

  ;; Autoload all these commands that org-attach doesn't autoload itself
  (use-package! org-attach
    :commands (org-attach-new
               org-attach-open
               org-attach-open-in-emacs
               org-attach-reveal-in-emacs
               org-attach-url
               org-attach-set-directory
               org-attach-sync)
    :config
    (unless org-attach-id-dir
      ;; Centralized attachments directory by default
      (setq-default org-attach-id-dir (expand-file-name ".attach/" org-directory)))
    (after! projectile
      (add-to-list 'projectile-globally-ignored-directories org-attach-id-dir)))

  ;; Add inline image previews for attachment links
  (org-link-set-parameters "attachment" :image-data-fun #'+org-inline-image-data-fn))


(defun +org-init-custom-links-h ()
  ;; Highlight broken file links
  (org-link-set-parameters
   "file"
   :face (lambda (path)
           (if (or (file-remote-p path)
                   ;; filter out network shares on windows (slow)
                   (and IS-WINDOWS (string-prefix-p "\\\\" path))
                   (file-exists-p path))
               'org-link
             '(warning org-link))))

  ;; Add custom link types
  (pushnew! org-link-abbrev-alist
            '("github"      . "https://github.com/%s")
            '("youtube"     . "https://youtube.com/watch?v=%s")
            '("google"      . "https://google.com/search?q=")
            '("gimages"     . "https://google.com/images?q=%s")
            '("gmap"        . "https://maps.google.com/maps?q=%s")
            '("duckduckgo"  . "https://duckduckgo.com/?q=%s")
            '("wikipedia"   . "https://en.wikipedia.org/wiki/%s")
            '("wolfram"     . "https://wolframalpha.com/input/?i=%s")
            '("doom-repo"   . "https://github.com/hlissner/doom-emacs/%s"))

  (+org-define-basic-link "org" 'org-directory)
  (+org-define-basic-link "doom" 'doom-emacs-dir)
  (+org-define-basic-link "doom-docs" 'doom-docs-dir)
  (+org-define-basic-link "doom-modules" 'doom-modules-dir)

  ;; Allow inline image previews of http(s)? urls or data uris.
  ;; `+org-http-image-data-fn' will respect `org-display-remote-inline-images'.
  (setq org-display-remote-inline-images 'download) ; TRAMP urls
  (org-link-set-parameters "http"  :image-data-fun #'+org-http-image-data-fn)
  (org-link-set-parameters "https" :image-data-fun #'+org-http-image-data-fn)
  (org-link-set-parameters "img"   :image-data-fun #'+org-inline-image-data-fn)

  ;; Add support for youtube links + previews
  (require 'org-yt nil t)

  (defadvice! +org-dont-preview-if-disabled-a (&rest _)
    "Make `org-yt' respect `org-display-remote-inline-images'."
    :before-while #'org-yt-image-data-fun
    (not (eq org-display-remote-inline-images 'skip))))


(defun +org-init-export-h ()
  "TODO"
  (setq org-export-with-smart-quotes t
        org-html-validation-link nil
        org-latex-prefer-user-labels t)

  (when (featurep! :lang markdown)
    (add-to-list 'org-export-backends 'md))

  (use-package! ox-hugo
    :when (featurep! +hugo)
    :after ox)

  (use-package! ox-pandoc
    :when (featurep! +pandoc)
    :when (executable-find "pandoc")
    :after ox
    :init
    (add-to-list 'org-export-backends 'pandoc)
    (setq org-pandoc-options
          '((standalone . t)
            (mathjax . t)
            (variable . "revealjs-url=https://revealjs.com"))))

  (defadvice! +org--dont-trigger-save-hooks-a (orig-fn &rest args)
    "Exporting and tangling trigger save hooks; inadvertantly triggering
mutating hooks on exported output, like formatters."
    :around '(org-export-to-file org-babel-tangle)
    (let (before-save-hook after-save-hook)
      (apply orig-fn args)))

  (defadvice! +org--fix-async-export-a (orig-fn &rest args)
    :around '(org-export-to-file org-export-as)
    (let ((old-async-init-file org-export-async-init-file)
          (org-export-async-init-file (make-temp-file "doom-org-async-export")))
      (with-temp-file org-export-async-init-file
        (prin1 `(progn (setq org-export-async-debug
                             ,(or org-export-async-debug
                                  debug-on-error)
                             load-path ',load-path)
                       (unwind-protect
                           (load ,(or old-async-init-file user-init-file)
                                 nil t)
                         (delete-file load-file-name)))
               (current-buffer)))
      (apply orig-fn args))))


(defun +org-init-habit-h ()
  (add-hook! 'org-agenda-mode-hook
    (defun +org-habit-resize-graph-h ()
      "Right align and resize the consistency graphs based on
`+org-habit-graph-window-ratio'"
      (when (featurep 'org-habit)
        (let* ((total-days (float (+ org-habit-preceding-days org-habit-following-days)))
               (preceding-days-ratio (/ org-habit-preceding-days total-days))
               (graph-width (floor (* (window-width) +org-habit-graph-window-ratio)))
               (preceding-days (floor (* graph-width preceding-days-ratio)))
               (following-days (- graph-width preceding-days))
               (graph-column (- (window-width) (+ preceding-days following-days)))
               (graph-column-adjusted (if (> graph-column +org-habit-min-width)
                                          (- graph-column +org-habit-graph-padding)
                                        nil)))
          (setq-local org-habit-preceding-days preceding-days)
          (setq-local org-habit-following-days following-days)
          (setq-local org-habit-graph-column graph-column-adjusted))))))


(defun +org-init-hacks-h ()
  "Getting org to behave."
  ;; Open file links in current window, rather than new ones
  (setf (alist-get 'file org-link-frame-setup) #'find-file)
  ;; Open directory links in dired
  (add-to-list 'org-file-apps '(directory . emacs))
  (add-to-list 'org-file-apps '(remote . emacs))

  ;; Some uses of `org-fix-tags-on-the-fly' occur without a check on
  ;; `org-auto-align-tags', such as in `org-self-insert-command' and
  ;; `org-delete-backward-char'.
  ;; TODO Should be reported/PR'ed upstream
  (defadvice! +org--respect-org-auto-align-tags-a (&rest _)
    :before-while #'org-fix-tags-on-the-fly
    org-auto-align-tags)

  (defadvice! +org--recenter-after-follow-link-a (&rest _args)
    "Recenter after following a link, but only internal or file links."
    :after '(org-footnote-action
             org-follow-timestamp-link
             org-link-open-as-file
             org-link-search)
    (when (get-buffer-window)
      (recenter)))

  (defadvice! +org--strip-properties-from-outline-a (orig-fn &rest args)
    "Fix variable height faces in eldoc breadcrumbs."
    :around #'org-format-outline-path
    (let ((org-level-faces
           (cl-loop for face in org-level-faces
                    collect `(:foreground ,(face-foreground face nil t)
                              :weight bold))))
      (apply orig-fn args)))

  (after! org-eldoc
    ;; HACK Fix #2972: infinite recursion when eldoc kicks in in 'org' or
    ;;      'python' src blocks.
    ;; TODO Should be reported upstream!
    (puthash "org" #'ignore org-eldoc-local-functions-cache)
    (puthash "plantuml" #'ignore org-eldoc-local-functions-cache)
    (puthash "python" #'python-eldoc-function org-eldoc-local-functions-cache))

  (defun +org--restart-mode-h ()
    "Restart `org-mode', but only once."
    (quiet! (org-mode-restart))
    (delq! (current-buffer) org-agenda-new-buffers)
    (remove-hook 'doom-switch-buffer-hook #'+org--restart-mode-h
                 'local)
    (run-hooks 'find-file-hook))

  (add-hook! 'org-agenda-finalize-hook
    (defun +org-exclude-agenda-buffers-from-workspace-h ()
      "Don't associate temporary agenda buffers with current workspace."
      (when (and org-agenda-new-buffers
                 (bound-and-true-p persp-mode)
                 (not org-agenda-sticky))
        (let (persp-autokill-buffer-on-remove)
          (persp-remove-buffer org-agenda-new-buffers
                               (get-current-persp)
                               nil))))
    (defun +org-defer-mode-in-agenda-buffers-h ()
      "`org-agenda' opens temporary, incomplete org-mode buffers.
I've disabled a lot of org-mode's startup processes for these invisible buffers
to speed them up (in `+org--exclude-agenda-buffers-from-recentf-a'). However, if
the user tries to visit one of these buffers they'll see a gimped, half-broken
org buffer. To avoid that, restart `org-mode' when they're switched to so they
can grow up to be fully-fledged org-mode buffers."
      (dolist (buffer org-agenda-new-buffers)
        (with-current-buffer buffer
          (add-hook 'doom-switch-buffer-hook #'+org--restart-mode-h
                    nil 'local)))))

  (defvar recentf-exclude)
  (defadvice! +org--optimize-backgrounded-agenda-buffers-a (orig-fn file)
    "Prevent temporarily opened agenda buffers from polluting recentf."
    :around #'org-get-agenda-file-buffer
    (let ((recentf-exclude (list (lambda (_file) t)))
          (doom-inhibit-large-file-detection t)
          org-startup-indented
          org-startup-folded
          vc-handled-backends
          org-mode-hook
          find-file-hook)
      (funcall orig-fn file)))

  ;; HACK With https://code.orgmode.org/bzg/org-mode/commit/48da60f4, inline
  ;;      image previews broke for users with imagemagick support built in. This
  ;;      reverses the problem, but should be removed once it is addressed
  ;;      upstream (if ever).
  (defadvice! +org--fix-inline-images-for-imagemagick-users-a (orig-fn &rest args)
    :around #'org-display-inline-images
    (letf! (defun create-image (file-or-data &optional type data-p &rest props)
             (let ((type (if (plist-get props :width) type)))
               (apply create-image file-or-data type data-p props)))
      (apply orig-fn args)))

  (defadvice! +org--fix-inconsistent-uuidgen-case-a (uuid)
    "Ensure uuidgen always produces lowercase output regardless of system."
    :filter-return #'org-id-new
    (if (eq org-id-method 'uuid)
        (downcase uuid)
      uuid)))


(defun +org-init-keybinds-h ()
  "Sets up org-mode and evil keybindings. Tries to fix the idiosyncrasies
between the two."
  (add-hook 'doom-escape-hook #'+org-remove-occur-highlights-h)

  ;; C-a & C-e act like `doom/backward-to-bol-or-indent' and
  ;; `doom/forward-to-last-non-comment-or-eol', but with more org awareness.
  (setq org-special-ctrl-a/e t)

  (setq org-M-RET-may-split-line nil
        ;; insert new headings after current subtree rather than inside it
        org-insert-heading-respect-content t)

  (add-hook! 'org-tab-first-hook
             #'+org-yas-expand-maybe-h
             #'+org-indent-maybe-h)

  (add-hook 'doom-delete-backward-functions
            #'+org-delete-backward-char-and-realign-table-maybe-h)

  (map! :map org-mode-map
        "C-c C-S-l"  #'+org/remove-link
        "C-c C-i"    #'org-toggle-inline-images
        ;; textmate-esque newline insertion
        "S-RET"      #'+org/shift-return
        "C-RET"      #'+org/insert-item-below
        "C-S-RET"    #'+org/insert-item-above
        "C-M-RET"    #'org-insert-subheading
        [C-return]   #'+org/insert-item-below
        [C-S-return] #'+org/insert-item-above
        [C-M-return] #'org-insert-subheading
        (:when IS-MAC
         [s-return]   #'+org/insert-item-below
         [s-S-return] #'+org/insert-item-above
         [s-M-return] #'org-insert-subheading)
        ;; Org-aware C-a/C-e
        [remap doom/backward-to-bol-or-indent]          #'org-beginning-of-line
        [remap doom/forward-to-last-non-comment-or-eol] #'org-end-of-line

        :localleader
        "#" #'org-update-statistics-cookies
        "'" #'org-edit-special
        "*" #'org-ctrl-c-star
        "+" #'org-ctrl-c-minus
        "," #'org-switchb
        "." #'org-goto
        (:when (featurep! :completion ivy)
         "." #'counsel-org-goto
         "/" #'counsel-org-goto-all)
        (:when (featurep! :completion helm)
         "." #'helm-org-in-buffer-headings
         "/" #'helm-org-agenda-files-headings)
        (:when (featurep! :completion vertico)
         "." #'consult-org-heading
         "/" #'consult-org-agenda)
        "A" #'org-archive-subtree
        "e" #'org-export-dispatch
        "f" #'org-footnote-new
        "h" #'org-toggle-heading
        "i" #'org-toggle-item
        "I" #'org-toggle-inline-images
        "n" #'org-store-link
        "o" #'org-set-property
        "q" #'org-set-tags-command
        "t" #'org-todo
        "T" #'org-todo-list
        "x" #'org-toggle-checkbox
        (:prefix ("a" . "attachments")
         "a" #'org-attach
         "d" #'org-attach-delete-one
         "D" #'org-attach-delete-all
         "f" #'+org/find-file-in-attachments
         "l" #'+org/attach-file-and-insert-link
         "n" #'org-attach-new
         "o" #'org-attach-open
         "O" #'org-attach-open-in-emacs
         "r" #'org-attach-reveal
         "R" #'org-attach-reveal-in-emacs
         "u" #'org-attach-url
         "s" #'org-attach-set-directory
         "S" #'org-attach-sync
         (:when (featurep! +dragndrop)
          "c" #'org-download-screenshot
          "p" #'org-download-clipboard
          "P" #'org-download-yank))
        (:prefix ("b" . "tables")
         "-" #'org-table-insert-hline
         "a" #'org-table-align
         "b" #'org-table-blank-field
         "c" #'org-table-create-or-convert-from-region
         "e" #'org-table-edit-field
         "f" #'org-table-edit-formulas
         "h" #'org-table-field-info
         "s" #'org-table-sort-lines
         "r" #'org-table-recalculate
         "R" #'org-table-recalculate-buffer-tables
         (:prefix ("d" . "delete")
          "c" #'org-table-delete-column
          "r" #'org-table-kill-row)
         (:prefix ("i" . "insert")
          "c" #'org-table-insert-column
          "h" #'org-table-insert-hline
          "r" #'org-table-insert-row
          "H" #'org-table-hline-and-move)
         (:prefix ("t" . "toggle")
          "f" #'org-table-toggle-formula-debugger
          "o" #'org-table-toggle-coordinate-overlays)
         (:when (featurep! +gnuplot)
          "p" #'org-plot/gnuplot))
        (:prefix ("c" . "clock")
         "c" #'org-clock-cancel
         "d" #'org-clock-mark-default-task
         "e" #'org-clock-modify-effort-estimate
         "E" #'org-set-effort
         "g" #'org-clock-goto
         "G" (cmd! (org-clock-goto 'select))
         "l" #'+org/toggle-last-clock
         "i" #'org-clock-in
         "I" #'org-clock-in-last
         "o" #'org-clock-out
         "r" #'org-resolve-clocks
         "R" #'org-clock-report
         "t" #'org-evaluate-time-range
         "=" #'org-clock-timestamps-up
         "-" #'org-clock-timestamps-down)
        (:prefix ("d" . "date/deadline")
         "d" #'org-deadline
         "s" #'org-schedule
         "t" #'org-time-stamp
         "T" #'org-time-stamp-inactive)
        (:prefix ("g" . "goto")
         "g" #'org-goto
         (:when (featurep! :completion ivy)
          "g" #'counsel-org-goto
          "G" #'counsel-org-goto-all)
         (:when (featurep! :completion helm)
          "g" #'helm-org-in-buffer-headings
          "G" #'helm-org-agenda-files-headings)
        (:when (featurep! :completion vertico)
         "g" #'consult-org-heading
         "G" #'consult-org-agenda)
         "c" #'org-clock-goto
         "C" (cmd! (org-clock-goto 'select))
         "i" #'org-id-goto
         "r" #'org-refile-goto-last-stored
         "v" #'+org/goto-visible
         "x" #'org-capture-goto-last-stored)
        (:prefix ("l" . "links")
         "c" #'org-cliplink
         "d" #'+org/remove-link
         "i" #'org-id-store-link
         "l" #'org-insert-link
         "L" #'org-insert-all-links
         "s" #'org-store-link
         "S" #'org-insert-last-stored-link
         "t" #'org-toggle-link-display)
        (:prefix ("P" . "publish")
         "a" #'org-publish-all
         "f" #'org-publish-current-file
         "p" #'org-publish
         "P" #'org-publish-current-project
         "s" #'org-publish-sitemap)
        (:prefix ("r" . "refile")
         "." #'+org/refile-to-current-file
         "c" #'+org/refile-to-running-clock
         "l" #'+org/refile-to-last-location
         "f" #'+org/refile-to-file
         "o" #'+org/refile-to-other-window
         "O" #'+org/refile-to-other-buffer
         "v" #'+org/refile-to-visible
         "r" #'org-refile) ; to all `org-refile-targets'
        (:prefix ("s" . "tree/subtree")
         "a" #'org-toggle-archive-tag
         "b" #'org-tree-to-indirect-buffer
         "d" #'org-cut-subtree
         "h" #'org-promote-subtree
         "j" #'org-move-subtree-down
         "k" #'org-move-subtree-up
         "l" #'org-demote-subtree
         "n" #'org-narrow-to-subtree
         "r" #'org-refile
         "s" #'org-sparse-tree
         "A" #'org-archive-subtree
         "N" #'widen
         "S" #'org-sort)
        (:prefix ("p" . "priority")
         "d" #'org-priority-down
         "p" #'org-priority
         "u" #'org-priority-up))

  (map! :after org-agenda
        :map org-agenda-mode-map
        :m "C-SPC" #'org-agenda-show-and-scroll-up
        :localleader
        (:prefix ("d" . "date/deadline")
         "d" #'org-agenda-deadline
         "s" #'org-agenda-schedule)
        (:prefix ("c" . "clock")
         "c" #'org-agenda-clock-cancel
         "g" #'org-agenda-clock-goto
         "i" #'org-agenda-clock-in
         "o" #'org-agenda-clock-out
         "r" #'org-agenda-clockreport-mode
         "s" #'org-agenda-show-clocking-issues)
        (:prefix ("p" . "priority")
         "d" #'org-agenda-priority-down
         "p" #'org-agenda-priority
         "u" #'org-agenda-priority-up)
        "q" #'org-agenda-set-tags
        "r" #'org-agenda-refile
        "t" #'org-agenda-todo))


(defun +org-init-popup-rules-h ()
  (set-popup-rules!
    '(("^\\*Org Links" :slot -1 :vslot -1 :size 2 :ttl 0)
      ("^ ?\\*\\(?:Agenda Com\\|Calendar\\|Org Export Dispatcher\\)"
       :slot -1 :vslot -1 :size #'+popup-shrink-to-fit :ttl 0)
      ("^\\*Org \\(?:Select\\|Attach\\)" :slot -1 :vslot -2 :ttl 0 :size 0.25)
      ("^\\*Org Agenda"     :ignore t)
      ("^\\*Org Src"        :size 0.4  :quit nil :select t :autosave t :modeline t :ttl nil)
      ("^\\*Org-Babel")
      ("^\\*Capture\\*$\\|CAPTURE-.*$" :size 0.25 :quit nil :select t :autosave ignore))))


(defun +org-init-protocol-lazy-loader-h ()
  "Brings lazy-loaded support for org-protocol, so external programs (like
browsers) can invoke specialized behavior from Emacs. Normally you'd simply
require `org-protocol' and use it, but the package loads all of org for no
compelling reason, so..."
  (defadvice! +org--server-visit-files-a (args)
    "Advise `server-visit-flist' to invoke `org-protocol' lazily."
    :filter-args #'server-visit-files
    (cl-destructuring-bind (files proc &optional nowait) args
      (catch 'greedy
        (let ((flist (reverse files)))
          (dolist (var flist)
            (when (string-match-p ":/+" (car var))
              (require 'server)
              (require 'org-protocol)
              ;; `\' to `/' on windows
              (let ((fname (org-protocol-check-filename-for-protocol
                            (expand-file-name (car var))
                            (member var flist)
                            proc)))
                (cond ((eq fname t) ; greedy? We need the t return value.
                       (setq files nil)
                       (throw 'greedy t))
                      ((stringp fname) ; probably filename
                       (setcar var fname))
                      ((setq files (delq var files)))))))))
      (list files proc nowait)))

  ;; Disable built-in, clumsy advice
  (after! org-protocol
    (ad-disable-advice 'server-visit-files 'before 'org-protocol-detect-protocol-server)))


(defun +org-init-protocol-h ()
  ;; TODO org-board or better link grabbing support
  ;; TODO org-capture + org-protocol instead of bin/org-capture
  )


(defun +org-init-smartparens-h ()
  ;; Disable the slow defaults
  (provide 'smartparens-org))


;;
;;; Packages

(use-package! toc-org ; auto-table of contents
  :hook (org-mode . toc-org-enable)
  :config
  (setq toc-org-hrefify-default "gh")

  (defadvice! +org-inhibit-scrolling-a (orig-fn &rest args)
    "Prevent the jarring scrolling that occurs when the-ToC is regenerated."
    :around #'toc-org-insert-toc
    (let ((p (set-marker (make-marker) (point)))
          (s (window-start)))
      (prog1 (apply orig-fn args)
        (goto-char p)
        (set-window-start nil s t)
        (set-marker p nil)))))


(use-package! org-crypt ; built-in
  :commands org-encrypt-entries org-encrypt-entry org-decrypt-entries org-decrypt-entry
  :hook (org-reveal-start . org-decrypt-entry)
  :preface
  ;; org-crypt falls back to CRYPTKEY property then `epa-file-encrypt-to', which
  ;; is a better default than the empty string `org-crypt-key' defaults to.
  (defvar org-crypt-key nil)
  (after! org
    (add-to-list 'org-tags-exclude-from-inheritance "crypt")
    (add-hook! 'org-mode-hook
      (add-hook 'before-save-hook 'org-encrypt-entries nil t))))


(use-package! org-clock ; built-in
  :commands org-clock-save
  :init
  (setq org-clock-persist-file (concat doom-etc-dir "org-clock-save.el"))
  (defadvice! +org--clock-load-a (&rest _)
    "Lazy load org-clock until its commands are used."
    :before '(org-clock-in
              org-clock-out
              org-clock-in-last
              org-clock-goto
              org-clock-cancel)
    (org-clock-load))
  :config
  (setq org-clock-persist 'history
        ;; Resume when clocking into task with open clock
        org-clock-in-resume t
        ;; Remove log if task was clocked for 0:00 (accidental clocking)
        org-clock-out-remove-zero-time-clocks t)
  (add-hook 'kill-emacs-hook #'org-clock-save))


(use-package! org-pdftools
  :when (featurep! :tools pdf)
  :commands org-pdftools-export
  :init
  (after! org
    (org-link-set-parameters (or (bound-and-true-p org-pdftools-link-prefix) "pdf")
                             :follow #'org-pdftools-open
                             :complete #'org-pdftools-complete-link
                             :store #'org-pdftools-store-link
                             :export #'org-pdftools-export)
    (add-hook! 'org-open-link-functions
      (defun +org-open-legacy-pdf-links-fn (link)
        "Open pdftools:* and pdfviews:* links as if they were pdf:* links."
        (let ((regexp "^pdf\\(?:tools\\|view\\):"))
          (when (string-match-p regexp link)
            (org-pdftools-open (replace-regexp-in-string regexp "" link))
            t))))))


(use-package! evil-org
  :when (featurep! :editor evil +everywhere)
  :hook (org-mode . evil-org-mode)
  :hook (org-capture-mode . evil-insert-state)
  :init
  (defvar evil-org-retain-visual-state-on-shift t)
  (defvar evil-org-special-o/O '(table-row))
  (defvar evil-org-use-additional-insert t)
  :config
  (add-hook 'evil-org-mode-hook #'evil-normalize-keymaps)
  (evil-org-set-key-theme)
  (add-hook! 'org-tab-first-hook :append
             ;; Only fold the current tree, rather than recursively
             #'+org-cycle-only-current-subtree-h
             ;; Clear babel results if point is inside a src block
             #'+org-clear-babel-results-h)
  (let-alist evil-org-movement-bindings
    (let ((Cright  (concat "C-" .right))
          (Cleft   (concat "C-" .left))
          (Cup     (concat "C-" .up))
          (Cdown   (concat "C-" .down))
          (CSright (concat "C-S-" .right))
          (CSleft  (concat "C-S-" .left))
          (CSup    (concat "C-S-" .up))
          (CSdown  (concat "C-S-" .down)))
      (map! :map evil-org-mode-map
            :ni [C-return]   #'+org/insert-item-below
            :ni [C-S-return] #'+org/insert-item-above
            ;; navigate table cells (from insert-mode)
            :i Cright (cmds! (org-at-table-p) #'org-table-next-field
                             #'org-end-of-line)
            :i Cleft  (cmds! (org-at-table-p) #'org-table-previous-field
                             #'org-beginning-of-line)
            :i Cup    (cmds! (org-at-table-p) #'+org/table-previous-row
                             #'org-up-element)
            :i Cdown  (cmds! (org-at-table-p) #'org-table-next-row
                             #'org-down-element)
            :ni CSright   #'org-shiftright
            :ni CSleft    #'org-shiftleft
            :ni CSup      #'org-shiftup
            :ni CSdown    #'org-shiftdown
            ;; more intuitive RET keybinds
            :n [return]   #'+org/dwim-at-point
            :n "RET"      #'+org/dwim-at-point
            :i [return]   (cmd! (org-return electric-indent-mode))
            :i "RET"      (cmd! (org-return electric-indent-mode))
            :i [S-return] #'+org/shift-return
            :i "S-RET"    #'+org/shift-return
            ;; more vim-esque org motion keys (not covered by evil-org-mode)
            :m "]h"  #'org-forward-heading-same-level
            :m "[h"  #'org-backward-heading-same-level
            :m "]l"  #'org-next-link
            :m "[l"  #'org-previous-link
            :m "]c"  #'org-babel-next-src-block
            :m "[c"  #'org-babel-previous-src-block
            :n "gQ"  #'org-fill-paragraph
            ;; sensible vim-esque folding keybinds
            :n "za"  #'+org/toggle-fold
            :n "zA"  #'org-shifttab
            :n "zc"  #'+org/close-fold
            :n "zC"  #'outline-hide-subtree
            :n "zm"  #'+org/hide-next-fold-level
            :n "zM"  #'+org/close-all-folds
            :n "zn"  #'org-tree-to-indirect-buffer
            :n "zo"  #'+org/open-fold
            :n "zO"  #'outline-show-subtree
            :n "zr"  #'+org/show-next-fold-level
            :n "zR"  #'+org/open-all-folds
            :n "zi"  #'org-toggle-inline-images

            :map org-read-date-minibuffer-local-map
            Cleft    (cmd! (org-eval-in-calendar '(calendar-backward-day 1)))
            Cright   (cmd! (org-eval-in-calendar '(calendar-forward-day 1)))
            Cup      (cmd! (org-eval-in-calendar '(calendar-backward-week 1)))
            Cdown    (cmd! (org-eval-in-calendar '(calendar-forward-week 1)))
            CSleft   (cmd! (org-eval-in-calendar '(calendar-backward-month 1)))
            CSright  (cmd! (org-eval-in-calendar '(calendar-forward-month 1)))
            CSup     (cmd! (org-eval-in-calendar '(calendar-backward-year 1)))
            CSdown   (cmd! (org-eval-in-calendar '(calendar-forward-year 1)))))))


(use-package! evil-org-agenda
  :when (featurep! :editor evil +everywhere)
  :hook (org-agenda-mode . evil-org-agenda-mode)
  :config
  (evil-org-agenda-set-keys)
  (evil-define-key* 'motion evil-org-agenda-mode-map
    (kbd doom-leader-key) nil))


;;
;;; Bootstrap

(use-package! org
  :defer-incrementally
  calendar find-func format-spec org-macs org-compat org-faces org-entities
  org-list org-pcomplete org-src org-footnote org-macro ob org org-agenda
  org-capture
  :preface
  ;; Set to nil so we can detect user changes to them later (and fall back on
  ;; defaults otherwise).
  (defvar org-directory nil)
  (defvar org-id-locations-file nil)
  (defvar org-attach-id-dir nil)

  (setq org-publish-timestamp-directory (concat doom-cache-dir "org-timestamps/")
        org-preview-latex-image-directory (concat doom-cache-dir "org-latex/")
        ;; Recognize a), A), a., A., etc -- must be set before org is loaded.
        org-list-allow-alphabetical t)

  ;; Make most of the default modules opt-in to lighten its first-time load
  ;; delay. I sincerely doubt most users use them all.
  (defvar org-modules
    '(;; ol-w3m
      ;; ol-bbdb
      ol-bibtex
      ;; ol-docview
      ;; ol-gnus
      ;; ol-info
      ;; ol-irc
      ;; ol-mhe
      ;; ol-rmail
      ;; ol-eww
      ))

  ;;; Custom org modules
  (dolist (flag doom--current-flags)
    (load! (concat "contrib/" (substring (symbol-name flag) 1)) nil t))

  ;; Add our general hooks after the submodules, so that any hooks the
  ;; submodules add run after them, and can overwrite any defaults if necessary.
  (add-hook! 'org-mode-hook
             ;; `show-paren-mode' causes flickering with indent overlays made by
             ;; `org-indent-mode', so we turn off show-paren-mode altogether
             #'doom-disable-show-paren-mode-h
             ;; disable `show-trailing-whitespace'; shows a lot of false positives
             #'doom-disable-show-trailing-whitespace-h
             #'+org-enable-auto-reformat-tables-h
             #'+org-enable-auto-update-cookies-h
             #'+org-make-last-point-visible-h)

  (add-hook! 'org-load-hook
             #'+org-init-org-directory-h
             #'+org-init-appearance-h
             #'+org-init-agenda-h
             #'+org-init-attachments-h
             #'+org-init-babel-h
             #'+org-init-babel-lazy-loader-h
             #'+org-init-capture-defaults-h
             #'+org-init-capture-frame-h
             #'+org-init-custom-links-h
             #'+org-init-export-h
             #'+org-init-habit-h
             #'+org-init-hacks-h
             #'+org-init-keybinds-h
             #'+org-init-popup-rules-h
             #'+org-init-protocol-h
             #'+org-init-protocol-lazy-loader-h
             #'+org-init-smartparens-h)

  ;; (Re)activate eldoc-mode in org-mode a little later, because it disables
  ;; itself if started too soon (which is the case with `global-eldoc-mode').
  (add-hook 'org-mode-local-vars-hook #'eldoc-mode)

  ;; In case the user has eagerly loaded org from their configs
  (when (and (featurep 'org)
             (not byte-compile-current-file))
    (unless doom-reloading-p
      (message "`org' was already loaded by the time lang/org loaded, this may cause issues"))
    (run-hooks 'org-load-hook))

  :config
  (add-to-list 'doom-debug-variables 'org-export-async-debug)

  (set-company-backend! 'org-mode 'company-capf)
  (set-eval-handler! 'org-mode #'+org-eval-handler)
  (set-lookup-handlers! 'org-mode
    :definition #'+org-lookup-definition-handler
    :references #'+org-lookup-references-handler
    :documentation #'+org-lookup-documentation-handler)

  ;; Save target buffer after archiving a node.
  (setq org-archive-subtree-save-file-p t)

  ;; Prevent modifications made in invisible sections of an org document, as
  ;; unintended changes can easily go unseen otherwise.
  (setq org-catch-invisible-edits 'smart)

  ;; Global ID state means we can have ID links anywhere. This is required for
  ;; `org-brain', however.
  (setq org-id-locations-file-relative t)

  ;; HACK `org-id' doesn't check if `org-id-locations-file' exists or is
  ;;      writeable before trying to read/write to it.
  (defadvice! +org--fail-gracefully-a (&rest _)
    :before-while '(org-id-locations-save org-id-locations-load)
    (file-writable-p org-id-locations-file))

  (add-hook 'org-open-at-point-functions #'doom-set-jump-h))
