;;; lang/dhall/config.el -*- lexical-binding: t; -*-

(use-package! dhall-mode
  :defer t
  :config
  (set-repl-handler! 'dhall-mode #'dhall-repl-show)
  (setq dhall-format-at-save (featurep! :editor format +onsave))
  (map! :map dhall-mode-map
        :localleader
        "l" #'dhall-lint
        "f" #'dhall-freeze
        "t" #'dhall-buffer-type-show))
