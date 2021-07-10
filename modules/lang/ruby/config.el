;;; lang/ruby/config.el -*- lexical-binding: t; -*-

(after! projectile
  (add-to-list 'projectile-project-root-files "Gemfile"))


;;
;;; Packages

(use-package! ruby-mode  ; built-in
  ;; Other extensions are already registered in `auto-mode-alist' by `ruby-mode'
  :mode "\\.\\(?:a?rb\\|aslsx\\)\\'"
  :mode "/\\(?:Brew\\|Fast\\)file\\'"
  :interpreter "j?ruby\\(?:[0-9.]+\\)"
  :config
  (setq ruby-insert-encoding-magic-comment nil)

  (set-electric! 'ruby-mode :words '("else" "end" "elsif"))
  (set-repl-handler! 'ruby-mode #'inf-ruby)

  (when (featurep! +lsp)
    (add-hook 'ruby-mode-local-vars-hook #'lsp!))

  (after! inf-ruby
    (add-hook 'inf-ruby-mode-hook #'doom-mark-buffer-as-real-h)
    ;; switch to inf-ruby from compile if we detect a breakpoint has been hit
    (add-hook 'compilation-filter-hook #'inf-ruby-auto-enter))

  ;; so class and module pairs work
  (setq-hook! 'ruby-mode-hook sp-max-pair-length 6)

  (map! :localleader
        :map ruby-mode-map
        "[" #'ruby-toggle-block
        "{" #'ruby-toggle-block))


(use-package! robe
  :defer t
  :init
  (add-hook! 'ruby-mode-hook
    (defun +ruby-init-robe-mode-maybe-h ()
      "Start `robe-mode' if `lsp-mode' isn't active."
      (or (bound-and-true-p lsp-mode)
          (bound-and-true-p lsp--buffer-deferred)
          (robe-mode +1))))
  :config
  (set-repl-handler! 'ruby-mode #'robe-start)
  (set-company-backend! 'ruby-mode 'company-robe 'company-dabbrev-code)
  (set-lookup-handlers! 'ruby-mode
    :definition #'robe-jump
    :documentation #'robe-doc)
  (when (boundp 'read-process-output-max)
    ;; Robe can over saturate IPC, making interacting with it slow/clobbering
    ;; the GC, so increase the amount of data Emacs reads from it at a time.
    (setq-hook! '(robe-mode-hook inf-ruby-mode-hook)
      read-process-output-max (* 1024 1024)))
  (when (featurep! :editor evil)
    (add-hook 'robe-mode-hook #'evil-normalize-keymaps))
  (map! :localleader
        :map robe-mode-map
        "'"  #'robe-start
        "h"  #'robe-doc
        "R"  #'robe-rails-refresh
        :prefix "s"
        "d"  #'ruby-send-definition
        "D"  #'ruby-send-definition-and-go
        "r"  #'ruby-send-region
        "R"  #'ruby-send-region-and-go
        "i"  #'ruby-switch-to-inf))


;; NOTE Must be loaded before `robe-mode'
(use-package! yard-mode
  :hook ruby-mode)


(use-package! rubocop
  :hook (ruby-mode . rubocop-mode)
  :config
  (set-popup-rule! "^\\*RuboCop" :select t)
  (map! :localleader
        :map rubocop-mode-map
        "f" #'rubocop-check-current-file
        "F" #'rubocop-autocorrect-current-file
        "p" #'rubocop-check-project
        "P" #'rubocop-autocorrect-project))


;;
;;; Package & Ruby version management

(use-package! rake
  :defer t
  :init
  (setq rake-cache-file (concat doom-cache-dir "rake.cache"))
  (setq rake-completion-system 'default)
  (map! :after ruby-mode
        :localleader
        :map ruby-mode-map
        :prefix ("k" . "rake")
        "k" #'rake
        "r" #'rake-rerun
        "R" #'rake-regenerate-cache
        "f" #'rake-find-task))

(use-package! bundler
  :defer t
  :init
  (map! :after ruby-mode
        :localleader
        :map ruby-mode-map
        :prefix ("b" . "bundle")
        "c" #'bundle-check
        "C" #'bundle-console
        "i" #'bundle-install
        "u" #'bundle-update
        "e" #'bundle-exec
        "o" #'bundle-open))

(use-package! chruby
  :when (featurep! +chruby)
  :hook (ruby-mode . chruby-use-corresponding)
  :config
  (setq rspec-use-rvm nil
        rspec-use-chruby t))

(after! rbenv
  (setq rspec-use-rvm nil)
  (add-to-list 'exec-path (expand-file-name "shims" rbenv-installation-dir)))


;;
;;; Testing frameworks

(use-package! rspec-mode
  :mode ("/\\.rspec\\'" . text-mode)
  :init
  (setq rspec-use-spring-when-possible nil)
  (when (featurep! :editor evil)
    (add-hook 'rspec-mode-hook #'evil-normalize-keymaps))
  :config
  (set-popup-rule! "^\\*\\(rspec-\\)?compilation" :size 0.3 :ttl nil :select t)
  (setq rspec-use-rvm (executable-find "rvm"))
  (map! :localleader
        :prefix "t"
        :map (rspec-verifiable-mode-map rspec-dired-mode-map rspec-mode-map)
        "a" #'rspec-verify-all
        "r" #'rspec-rerun
        :map (rspec-verifiable-mode-map rspec-mode-map)
        "v" #'rspec-verify
        "c" #'rspec-verify-continue
        "l" #'rspec-run-last-failed
        "T" #'rspec-toggle-spec-and-target
        "t" #'rspec-toggle-spec-and-target-find-example
        :map rspec-verifiable-mode-map
        "f" #'rspec-verify-method
        "m" #'rspec-verify-matching
        :map rspec-mode-map
        "s" #'rspec-verify-single
        "e" #'rspec-toggle-example-pendingness
        :map rspec-dired-mode-map
        "v" #'rspec-dired-verify
        "s" #'rspec-dired-verify-single))


(use-package! minitest
  :defer t
  :config
  (when (featurep! :editor evil)
    (add-hook 'minitest-mode-hook #'evil-normalize-keymaps))
  (map! :localleader
        :map minitest-mode-map
        :prefix "t"
        "r" #'minitest-rerun
        "a" #'minitest-verify-all
        "s" #'minitest-verify-single
        "v" #'minitest-verify))


(use-package! projectile-rails
  :when (featurep! +rails)
  :hook ((ruby-mode inf-ruby-mode projectile-rails-server-mode) . projectile-rails-mode)
  :hook (projectile-rails-server-mode . doom-mark-buffer-as-real-h)
  :hook (projectile-rails-mode . auto-insert-mode)
  :init
  (setq auto-insert-query nil)
  (setq inf-ruby-console-environment "development")
  (when (featurep! :lang web)
    (add-hook 'web-mode-hook #'projectile-rails-mode))
  :config
  (when (featurep! :editor file-templates)
    (defadvice! +projectile-rails-ignore-snippet-for-module-a (_last-part _name)
      "Use ruby-mode's __app_module file template by returning no snippet."
      :override 'projectile-rails--snippet-for-module
      nil))
  (set-popup-rule! "^\\*\\(projectile-\\)?rails" :ttl nil)
  (when (featurep! :editor evil)
    (add-hook 'projectile-rails-mode-hook #'evil-normalize-keymaps))
  (map! :localleader
        :map projectile-rails-mode-map
        "r" #'projectile-rails-command-map))
