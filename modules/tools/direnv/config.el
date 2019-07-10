;;; tools/direnv/config.el -*- lexical-binding: t; -*-

(def-package! direnv
  :after-call (after-find-file dired-initial-position-hook)
  :config
  (defun +direnv|init ()
    "Instead of checking for direnv on `post-command-hook', check on
buffer/window/frame switch, which is less expensive."
    (direnv--disable)
    (when direnv-mode
      (add-hook 'doom-switch-buffer-hook #'direnv--maybe-update-environment)
      (add-hook 'doom-switch-window-hook #'direnv--maybe-update-environment)
      (add-hook 'doom-switch-frame-hook #'direnv--maybe-update-environment)
      (add-hook 'focus-in-hook #'direnv--maybe-update-environment)))
  (add-hook 'direnv-mode-hook #'+direnv|init)

  (defun +direnv*update (&rest _)
    "Update direnv. Useful to advise functions that may run
environment-sensitive logic like `flycheck-default-executable-find'. This fixes
flycheck issues with direnv and on nix."
    (direnv-update-environment default-directory))
  (advice-add #'flycheck-default-executable-find :before #'+direnv*update)

  (when (executable-find "direnv")
    (direnv-mode +1)))
