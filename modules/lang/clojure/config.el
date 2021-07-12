;;; lang/clojure/config.el -*- lexical-binding: t; -*-

(after! projectile
  (pushnew! projectile-project-root-files "project.clj" "build.boot" "deps.edn"))

;; Large clojure buffers tend to be slower than large buffers of other modes, so
;; it should have a lower threshold too.
(add-to-list 'doom-large-file-size-alist '("\\.\\(?:clj[sc]?\\|dtm\\|edn\\)\\'" . 0.5))


;;
;;; Packages

(use-package! clojure-mode
  :hook (clojure-mode . rainbow-delimiters-mode)
  :config
  (when (featurep! +lsp)
    (add-hook! '(clojure-mode-local-vars-hook
                 clojurec-mode-local-vars-hook
                 clojurescript-mode-local-vars-hook)
      (defun +clojure-disable-lsp-indentation-h ()
        (setq-local lsp-enable-indentation nil))
      #'lsp!)
    (after! lsp-clojure
      (dolist (m '(clojure-mode
                   clojurec-mode
                   clojurescript-mode
                   clojurex-mode))
        (add-to-list 'lsp-language-id-configuration (cons m "clojure"))))))


(use-package! cider
  ;; NOTE if `org-directory' doesn't exist, `cider-jack' in won't work
  :hook (clojure-mode-local-vars . cider-mode)
  :init
  (after! clojure-mode
    (set-repl-handler! 'clojure-mode #'+clojure/open-repl :persist t)
    (set-repl-handler! 'clojurescript-mode #'+clojure/open-cljs-repl :persist t)
    (set-eval-handler! '(clojure-mode clojurescript-mode) #'cider-eval-region))
  :config
  (add-hook 'cider-mode-hook #'eldoc-mode)
  (set-lookup-handlers! '(cider-mode cider-repl-mode)
    :definition #'+clojure-cider-lookup-definition
    :documentation #'cider-doc)
  (set-popup-rules!
    '(("^\\*cider-error*" :ignore t)
      ("^\\*cider-repl" :quit nil :ttl nil)
      ("^\\*cider-repl-history" :vslot 2 :ttl nil)))

  (setq nrepl-hide-special-buffers t
        nrepl-log-messages nil
        cider-font-lock-dynamically '(macro core function var deprecated)
        cider-overlays-use-font-lock t
        cider-prompt-for-symbol nil
        cider-repl-history-display-duplicates nil
        cider-repl-history-display-style 'one-line
        cider-repl-history-file (concat doom-cache-dir "cider-repl-history")
        cider-repl-history-highlight-current-entry t
        cider-repl-history-quit-action 'delete-and-restore
        cider-repl-history-highlight-inserted-item t
        cider-repl-history-size 1000
        cider-repl-result-prefix ";; => "
        cider-repl-print-length 100
        cider-repl-use-clojure-font-lock t
        cider-repl-use-pretty-printing t
        cider-repl-wrap-history nil
        cider-stacktrace-default-filters '(tooling dup)

        ;; Don't focus the CIDER REPL when it starts. Since it can take so long
        ;; to start up, you either wait for a minute doing nothing or be
        ;; prepared for your cursor to suddenly change buffers without warning.
        ;; See https://github.com/clojure-emacs/cider/issues/1872
        cider-repl-pop-to-buffer-on-connect 'display-only)

  ;; Error messages emitted from CIDER is silently funneled into *nrepl-server*
  ;; rather than the *cider-repl* buffer. How silly. We might want to see that
  ;; stuff and who's going to check *nrepl-server* on every startup? I've got a
  ;; better idea: we copy these errors into the *cider-repl* buffer.
  (add-hook! 'cider-connected-hook
    (defun +clojure--cider-dump-nrepl-server-log-h ()
      "Copy contents of *nrepl-server* to beginning of *cider-repl*."
      (when (buffer-live-p nrepl-server-buffer)
        (save-excursion
          (goto-char (point-min))
          (insert
           (with-current-buffer nrepl-server-buffer
             (buffer-string)))))))

  ;; When in cider-debug-mode, override evil keys to not interfere with debug keys
  (after! evil
    (add-hook! cider--debug-mode
      (defun +clojure--cider-setup-debug ()
        "Setup cider debug to override evil keys cleanly"
        (evil-make-overriding-map cider--debug-mode-map 'normal)
        (evil-normalize-keymaps))))

  (when (featurep! :ui modeline +light)
    (defvar-local cider-modeline-icon nil)

    (add-hook! '(cider-connected-hook
                 cider-disconnected-hook
                 cider-mode-hook)
      (defun +clojure--cider-update-modeline ()
        "Update modeline with cider connection state."
        (let* ((connected (cider-connected-p))
               (face (if connected 'success 'warning))
               (label (if connected "Cider connected" "Cider disconnected")))
          (setq cider-modeline-icon (concat
                                     " "
                                     (+modeline-format-icon 'faicon "terminal" "" face label -0.0575)
                                     " "))
          (add-to-list 'global-mode-string
                       '(t (:eval cider-modeline-icon))
                       'append)))))

  ;; Ensure that CIDER is used for sessions in org buffers.
  (when (featurep! :lang org)
    (after! ob-clojure
      (setq! org-babel-clojure-backend 'cider)))

  ;; The CIDER welcome message obscures error messages that the above code is
  ;; supposed to be make visible.
  (setq cider-repl-display-help-banner nil)

  (map! (:localleader
          (:map (clojure-mode-map clojurescript-mode-map)
            "'"  #'cider-jack-in-clj
            "\"" #'cider-jack-in-cljs
            "c"  #'cider-connect-clj
            "C"  #'cider-connect-cljs
            "m"  #'cider-macroexpand-1
            "M"  #'cider-macroexpand-all
            (:prefix ("d" . "debug")
             "d" #'cider-debug-defun-at-point)
            (:prefix ("e" . "eval")
              "b" #'cider-eval-buffer
              "d" #'cider-eval-defun-at-point
              "D" #'cider-insert-defun-in-repl
              "e" #'cider-eval-last-sexp
              "E" #'cider-insert-last-sexp-in-repl
              "r" #'cider-eval-region
              "R" #'cider-insert-region-in-repl
              "u" #'cider-undef)
            (:prefix ("g" . "goto")
              "b" #'cider-pop-back
              "g" #'cider-find-var
              "n" #'cider-find-ns)
            (:prefix ("h" . "help")
              "n" #'cider-find-ns
              "a" #'cider-apropos
              "c" #'cider-clojuredocs
              "d" #'cider-doc
              "j" #'cider-javadoc
              "w" #'cider-clojuredocs-web)
            (:prefix ("i" . "inspect")
              "e" #'cider-enlighten-mode
              "i" #'cider-inspect
              "r" #'cider-inspect-last-result)
            (:prefix ("n" . "namespace")
              "n" #'cider-browse-ns
              "N" #'cider-browse-ns-all
              "r" #'cider-ns-refresh)
            (:prefix ("p" . "print")
              "p" #'cider-pprint-eval-last-sexp
              "P" #'cider-pprint-eval-last-sexp-to-comment
              "d" #'cider-pprint-eval-defun-at-point
              "D" #'cider-pprint-eval-defun-to-comment
              "r" #'cider-pprint-eval-last-sexp-to-repl)
            (:prefix ("r" . "repl")
              "n" #'cider-repl-set-ns
              "q" #'cider-quit
              "r" #'cider-ns-refresh
              "R" #'cider-restart
              "b" #'cider-switch-to-repl-buffer
              "B" #'+clojure/cider-switch-to-repl-buffer-and-switch-ns
              "c" #'cider-find-and-clear-repl-output
              "l" #'cider-load-buffer
              "L" #'cider-load-buffer-and-switch-to-repl-buffer)
            (:prefix ("t" . "test")
              "a" #'cider-test-rerun-test
              "l" #'cider-test-run-loaded-tests
              "n" #'cider-test-run-ns-tests
              "p" #'cider-test-run-project-tests
              "r" #'cider-test-rerun-failed-tests
              "s" #'cider-test-run-ns-tests-with-filters
              "t" #'cider-test-run-test)))

        (:when (featurep! :editor evil +everywhere)
          :map cider-repl-mode-map
          :i [S-return] #'cider-repl-newline-and-indent
          :i [M-return] #'cider-repl-return
          (:localleader
            "n" #'cider-repl-set-ns
            "q" #'cider-quit
            "r" #'cider-ns-refresh
            "R" #'cider-restart
            "c" #'cider-repl-clear-buffer)
          :map cider-repl-history-mode-map
          :i [return]  #'cider-repl-history-insert-and-quit
          :i "q"  #'cider-repl-history-quit
          :i "l"  #'cider-repl-history-occur
          :i "s"  #'cider-repl-history-search-forward
          :i "r"  #'cider-repl-history-search-backward
          :i "U"  #'cider-repl-history-undo-other-window)))


(after! cider-doc
  ;; Fixes raxod502/radian#446: CIDER tries to do color calculations when it's
  ;; loaded, sometimes too early, causing errors. Better to wait until something
  ;; is actually rendered.
  (setq cider-docview-code-background-color nil)

  (defadvice! +clojure--defer-color-calculation-a (&rest _)
    "Set `cider-docview-code-background-color'.
This is needed because we have ripped out the code that would normally set it
(since that code will run during early init, which is a problem)."
    :before #'cider-docview-fontify-code-blocks
    (setq cider-docview-code-background-color (cider-scale-background-color)))

  ;; HACK Disable cider's advice on these; and hope no one else is using these
  ;;      old-style advice.
  (ad-deactivate #'enable-theme)
  (ad-deactivate #'disable-theme))


(use-package! clj-refactor
  :hook (clojure-mode . clj-refactor-mode)
  :config
  (set-lookup-handlers! 'clj-refactor-mode
    :references #'cljr-find-usages)
  (map! :map clojure-mode-map
        :localleader
        :desc "refactor" "R" #'hydra-cljr-help-menu/body))


(use-package! flycheck-clj-kondo
  :when (featurep! :checkers syntax)
  :after flycheck)
