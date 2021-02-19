;;; completion/selectrum/config.el -*- lexical-binding: t; -*-

(use-package! selectrum
  :hook (doom-first-input . selectrum-mode)
  :init
  (setq selectrum-display-action nil
        selectrum-num-candidates-displayed 15
        selectrum-extend-current-candidate-highlight t
        selectrum-fix-minibuffer-height t)
  (unless (featurep! +orderless)
    (setq completion-styles '(substring partial-completion)))
  :config
  (setq selectrum-fix-vertical-window-height 17)
  (defadvice! +selectrum-refresh-on-cycle (&rest _)
    :after 'marginalia-cycle
    (when (bound-and-true-p selectrum-mode) (selectrum-exhibit))))

(use-package! selectrum-prescient
  :when (featurep! +prescient)
  :hook (selectrum-mode . selectrum-prescient-mode)
  :hook (selectrum-mode . prescient-persist-mode)
  :config
  (setq selectrum-preprocess-candidates-function #'selectrum-prescient--preprocess)
  (add-hook 'selectrum-candidate-selected-hook #'selectrum-prescient--remember)
  (add-hook 'selectrum-candidate-inserted-hook #'selectrum-prescient--remember))

(use-package! orderless
  :when (featurep! +orderless)
  :defer t
  :init
  (setq orderless-component-separator "[ &]"
        orderless-matching-styles '(orderless-prefixes
                                    orderless-initialism
                                    orderless-regexp))
  :config
  (setq completion-styles '(orderless))
  (setq orderless-skip-highlighting (lambda () selectrum-active-p))
  (setq selectrum-highlight-candidates-function #'orderless-highlight-matches
        selectrum-refine-candidates-function #'orderless-filter))

(use-package! consult
  :defer t
  :init
  (fset 'multi-occur #'consult-multi-occur)
  (define-key!
    [remap apropos] #'consult-apropos
    [remap bookmark-jump]  #'consult-bookmark
    [remap goto-line] #'consult-goto-line
    [remap imenu] #'consult-imenu
    [remap switch-to-buffer] #'consult-buffer
    [remap switch-to-buffer-other-window] #'consult-buffer-other-window
    [remap switch-to-buffer-other-frame] #'consult-buffer-other-frame
    [remap man] #'consult-man
    [remap yank-pop] #'consult-yank-pop
    [remap locate] #'consult-locate
    [remap load-theme] #'consult-theme
    [remap recentf-open-files] #'consult-recent-file)
  :config
  (setq consult-project-root-function #'doom-project-root)
  (setq completion-in-region-function #'consult-completion-in-region)
  (setq consult-narrow-key "<")
  (setq consult-line-numbers-widen t)
  (setq consult-async-input-debounce 0.5)
  (setq consult-async-input-throttle 0.8))

(use-package! consult-flycheck
  :when (featurep! :checkers syntax)
  :after (consult flycheck))

(use-package! embark
  :defer t
  :init
  (setq embark-action-indicator #'+embark-which-key-action-indicator
        embark-become-indicator embark-action-indicator))

(use-package! marginalia
  :after selectrum
  :hook (doom-first-input . marginalia-mode)
  :init
  (setq-default marginalia-annotators '(marginalia-annotators-heavy)))

(use-package! embark-consult
  :after (embark consult)
  :hook
  (embark-collect-mode . embark-consult-preview-minor-mode))
