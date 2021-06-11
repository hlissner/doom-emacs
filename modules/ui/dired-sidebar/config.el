;;; ui/dired-sidebar/config.el -*- lexical-binding: t; -*-

(use-package! dired-sidebar
  :unless (featurep! :emacs dired +ranger)
  :defer
  :config
  (setq dired-sidebar-width 25
        dired-sidebar-theme 'ascii
        dired-sidebar-tui-update-delay 5
        dired-sidebar-recenter-cursor-on-tui-update t
        dired-sidebar-no-delete-other-windows t
        dired-sidebar-use-custom-modeline t)
  (pushnew! dired-sidebar-toggle-hidden-commands
            'evil-window-rotate-upwards 'evil-window-rotate-downwards)
  (map! :map dired-sidebar-mode-map
        :n "q" #'dired-sidebar-toggle-sidebar))

(use-package! dired-subtree
  :unless (featurep! :emacs dired +ranger)
  :config
  (setq dired-subtree-cycle-depth 4
        dired-subtree-line-prefix ">")
  (map! :map dired-mode-map
        [backtab] #'dired-subtree-cycle
        [tab] #'dired-subtree-toggle
        :n "g^" #'dired-subtree-beginning
        :n "g$" #'dired-subtree-end
        :n "gm" #'dired-subtree-mark-subtree
        :n "gu" #'dired-subtree-unmark-subtree))
