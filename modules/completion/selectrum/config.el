;;; completion/selectrum/config.el -*- lexical-binding: t; -*-

(use-package! selectrum
  :hook (doom-first-input . selectrum-mode)
  :init
  (setq selectrum-display-action nil
        selectrum-extend-current-candidate-highlight t
        selectrum-fix-vertical-window-height 17
        selectrum-max-window-height 17)
  (when (featurep! +prescient)
    (setq completion-styles '(substring partial-completion)))
  :config
  (defadvice! +selectrum-refresh-on-cycle (&rest _)
    :after 'marginalia-cycle
    (when (bound-and-true-p selectrum-mode) (selectrum-exhibit)))
  (defun +selectrum/backward-updir ()
    "Delete char before or go up directory for file cagetory selectrum buffers."
    (interactive)
    (if (and (eq (char-before) ?/)
             (eq (selectrum--get-meta 'category) 'file))
        (let ((new-path (minibuffer-contents)))
          (delete-region (minibuffer-prompt-end) (point-max))
          (insert (abbreviate-file-name
                   (file-name-directory
                    (directory-file-name
                     (expand-file-name new-path))))))
      (call-interactively 'backward-delete-char)))
  (map! :map selectrum-minibuffer-map
        [backspace]         #'+selectrum/backward-updir))

(use-package! selectrum-prescient
  :when (featurep! +prescient)
  :hook (selectrum-mode . selectrum-prescient-mode)
  :hook (selectrum-mode . prescient-persist-mode)
  :config
  (setq selectrum-preprocess-candidates-function #'selectrum-prescient--preprocess)
  (add-hook 'selectrum-candidate-selected-hook #'selectrum-prescient--remember)
  (add-hook 'selectrum-candidate-inserted-hook #'selectrum-prescient--remember))

(use-package! orderless
  :when (not (featurep! +prescient))
  :demand t
  :config
  (defun +selectrum-orderless-dispatch (pattern _index _total)
    (cond
     ;; Ensure that $ works with Consult commands, which add disambiguation suffixes
     ((string-suffix-p "$" pattern) `(orderless-regexp . ,(concat (substring pattern 0 -1) "[\x100000-\x10FFFD]*$")))
     ;; Ignore single !
     ((string= "!" pattern) `(orderless-literal . ""))
     ;; Without literal
     ((string-prefix-p "!" pattern) `(orderless-without-literal . ,(substring pattern 1)))
     ;; Initialism matching
     ((string-prefix-p "`" pattern) `(orderless-initialism . ,(substring pattern 1)))
     ((string-suffix-p "`" pattern) `(orderless-initialism . ,(substring pattern 0 -1)))
     ;; Literal matching
     ((string-prefix-p "=" pattern) `(orderless-literal . ,(substring pattern 1)))
     ((string-suffix-p "=" pattern) `(orderless-literal . ,(substring pattern 0 -1)))
     ;; Flex matching
     ((string-prefix-p "~" pattern) `(orderless-flex . ,(substring pattern 1)))
     ((string-suffix-p "~" pattern) `(orderless-flex . ,(substring pattern 0 -1)))))
  (setq completion-styles '(orderless)
        completion-category-defaults nil
        ;; note that despite override in the name orderless can still be used in find-file etc.
        completion-category-overrides '((file (styles . (partial-completion))))
        orderless-style-dispatchers '(+selectrum-orderless-dispatch)
        orderless-component-separator "[ &]"
        selectrum-refine-candidates-function #'orderless-filter
        selectrum-highlight-candidates-function #'orderless-highlight-matches))

(use-package! consult
  :defer t
  :init
  (fset 'multi-occur #'consult-multi-occur)
  (define-key!
    [remap apropos]                       #'consult-apropos
    [remap bookmark-jump]                 #'consult-bookmark
    [remap evil-show-marks]               #'consult-mark
    [remap goto-line]                     #'consult-goto-line
    [remap imenu]                         #'consult-imenu
    [remap locate]                        #'consult-locate
    [remap load-theme]                    #'consult-theme
    [remap man]                           #'consult-man
    [remap recentf-open-files]            #'consult-recent-file
    [remap switch-to-buffer]              #'consult-buffer
    [remap switch-to-buffer-other-window] #'consult-buffer-other-window
    [remap switch-to-buffer-other-frame]  #'consult-buffer-other-frame
    [remap yank-pop]                      #'consult-yank-pop
    [remap persp-switch-to-buffer]        #'+selectrum/switch-workspace-buffer)
  (setq completion-in-region-function #'consult-completion-in-region)
  :config
  (recentf-mode)
  (setq consult-project-root-function #'doom-project-root
        completion-in-region-function #'consult-completion-in-region
        consult-narrow-key "<"
        consult-line-numbers-widen t
        consult-async-input-debounce 0.5
        consult-async-input-throttle 0.8)
  (consult-customize
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file
   +default/search-project +default/search-project-for-symbol-at-point
   +default/search-other-project +selectrum/search-symbol-at-point
   +default/search-cwd +default/search-other-cwd
   +default/search-notes-for-symbol-at-point
   consult--source-file consult--source-project-file consult--source-bookmark
   :preview-key (list (kbd "C-SPC") (kbd "C-M-j") (kbd "C-M-k"))))

(use-package! consult-flycheck
  :when (featurep! :checkers syntax)
  :after (consult flycheck))

(use-package! embark
  :init
  (setq embark-action-indicator
        (lambda (map _target)
          (which-key--show-keymap "Embark" map nil nil 'no-paging)
          #'which-key--hide-popup-ignore-command)
        embark-become-indicator embark-action-indicator)
  (map! "C-;"               #'embark-act  ; to be moved to :config default if accepted
        :leader
        :desc "Actions" "a" #'embark-act) ; to be moved to :config default if accepted
  (map! :map minibuffer-local-map
        "C-;"               #'embark-act
        "C-c C-;"           #'embark-export
        :desc "Export to writable buffer"
        "C-c C-e"           #'+selectrum/embark-export-write)
  (define-key!
    [remap describe-bindings]             #'embark-bindings)
  (defun +selectrum--embark-target-package! ()
    "Targets Doom's package! statements and returns the package name"
    (when (or (derived-mode-p 'emacs-lisp-mode) (derived-mode-p 'org-mode))
      (save-excursion
        (search-backward "(")
        (when (looking-at "(\\s-*package!\\s-*\\(\\(\\sw\\|\\s_\\)+\\)\\s-*")
          (let ((pkg (match-string 1)))
            (set-text-properties 0 (length pkg) nil pkg)
            `(package . ,pkg))))))
  :config
  ;; add the package! target finder before the file target finder,
  ;; so we don't get a false positive match.
  (let ((pos (or (cl-position
                  'embark-target-file-at-point
                   embark-target-finders)
                 (length embark-target-finders))))
    (cl-callf2
        cons
        '+selectrum--embark-target-package!
        (nthcdr pos embark-target-finders)))
  (map!
   :map embark-file-map
   :desc "Open target with sudo" "s" #'doom/sudo-find-file
   :desc "Open in new workspace" "TAB" #'+selectrum-embark-open-in-new-workspace)
  (setq embark-package-map (make-sparse-keymap))
  (map! :map embark-package-map
        "h" #'doom/help-packages
        "b" #'doom/bump-package
        "c" #'doom/help-package-config
        "u" #'doom/help-package-homepage)
  (set-popup-rule! "^\\*Embark Export" :size 0.35 :ttl 0 :quit nil)
  (set-popup-rule! "^\\*Embark Collect" :size 0.35 :ttl 0 :quit nil))

(use-package! marginalia
  :hook (doom-first-input . marginalia-mode)
  :init
  (map! :map minibuffer-local-map
        :desc "Cycle marginalia views"
        "M-A"               #'marginalia-cycle)
  :config
  (add-to-list 'marginalia-command-categories '(persp-switch-to-buffer . buffer)))

(use-package! embark-consult
  :after (embark consult)
  :demand t
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package! wgrep
  :commands wgrep-change-to-wgrep-mode
  :config (setq wgrep-auto-save-buffer t))
