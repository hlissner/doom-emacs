;;; tools/lsp/+lsp.el -*- lexical-binding: t; -*-

(defvar +lsp-company-backends
  (if (featurep! :editor snippets)
      '(company-capf :with company-yasnippet)
    'company-capf)
  "The backends to prepend to `company-backends' in `lsp-mode' buffers.
Can be a list of backends; accepts any value `company-backends' accepts.")

(defvar +lsp-prompt-to-install-server t
  "If non-nil, prompt to install a server if no server is present.

If set to `quiet', suppress the install prompt and don't visibly inform the user
about it (it will be logged to *Messages* however).")


;;
;;; Packages

(use-package! lsp-mode
  :commands lsp-install-server
  :init
  ;; Don't touch ~/.emacs.d, which could be purged without warning
  (setq lsp-session-file (concat doom-etc-dir "lsp-session")
        lsp-server-install-dir (concat doom-etc-dir "lsp"))
  ;; Don't auto-kill LSP server after last workspace buffer is killed, because I
  ;; will do it for you, after `+lsp-defer-shutdown' seconds.
  (setq lsp-keep-workspace-alive nil)

  ;; NOTE I tweak LSP's defaults in order to make its more expensive or imposing
  ;;      features opt-in. Some servers implement these poorly and, in most
  ;;      cases, it's safer to rely on Emacs' native mechanisms (eldoc vs
  ;;      lsp-ui-doc, open in popup vs sideline, etc).

  ;; Disable features that have great potential to be slow.
  (setq lsp-enable-folding nil
        lsp-enable-text-document-color nil)
  ;; Reduce unexpected modifications to code
  (setq lsp-enable-on-type-formatting nil)
  ;; Make breadcrumbs opt-in; they're redundant with the modeline and imenu
  (setq lsp-headerline-breadcrumb-enable nil)

  ;; Let doom bind the lsp keymap.
  (when (featurep! :config default +bindings)
    (setq lsp-keymap-prefix nil))

  :config
  (add-to-list 'doom-debug-variables 'lsp-log-io)

  (setq lsp-intelephense-storage-path (concat doom-etc-dir "lsp-intelephense/")
        lsp-vetur-global-snippets-dir
        (expand-file-name
         "vetur" (or (bound-and-true-p +snippets-dir)
                     (concat doom-private-dir "snippets/")))
        lsp-xml-jar-file (expand-file-name "org.eclipse.lsp4xml-0.3.0-uber.jar" lsp-server-install-dir)
        lsp-groovy-server-file (expand-file-name "groovy-language-server-all.jar" lsp-server-install-dir))

  (set-popup-rule! "^\\*lsp-help" :size 0.35 :quit t :select t)
  (set-lookup-handlers! 'lsp-mode
    :definition #'+lsp-lookup-definition-handler
    :references #'+lsp-lookup-references-handler
    :documentation '(lsp-describe-thing-at-point :async t)
    :implementations '(lsp-find-implementation :async t)
    :type-definition #'lsp-find-type-definition)

  (defadvice! +lsp--respect-user-defined-checkers-a (orig-fn &rest args)
    "Ensure user-defined `flycheck-checker' isn't overwritten by `lsp'."
    :around #'lsp-diagnostics-flycheck-enable
    (if flycheck-checker
        (let ((old-checker flycheck-checker))
          (apply orig-fn args)
          (setq-local flycheck-checker old-checker))
      (apply orig-fn args)))

  (add-hook! 'lsp-mode-hook
    (defun +lsp-display-guessed-project-root-h ()
      "Log what LSP things is the root of the current project."
      ;; Makes it easier to detect root resolution issues.
      (when-let (path (buffer-file-name (buffer-base-buffer)))
        (if-let (root (lsp--calculate-root (lsp-session) path))
            (lsp--info "Guessed project root is %s" (abbreviate-file-name root))
          (lsp--info "Could not guess project root."))))
    #'+lsp-optimization-mode)

  (add-hook! 'lsp-completion-mode-hook
    (defun +lsp-init-company-backends-h ()
      (when lsp-completion-mode
        (set (make-local-variable 'company-backends)
             (cons +lsp-company-backends
                   (remove +lsp-company-backends
                           (remq 'company-capf company-backends)))))))

  (defvar +lsp--deferred-shutdown-timer nil)
  (defadvice! +lsp-defer-server-shutdown-a (orig-fn &optional restart)
    "Defer server shutdown for a few seconds.
This gives the user a chance to open other project files before the server is
auto-killed (which is a potentially expensive process). It also prevents the
server getting expensively restarted when reverting buffers."
    :around #'lsp--shutdown-workspace
    (if (or lsp-keep-workspace-alive
            restart
            (null +lsp-defer-shutdown)
            (= +lsp-defer-shutdown 0))
        (prog1 (funcall orig-fn restart)
          (+lsp-optimization-mode -1))
      (when (timerp +lsp--deferred-shutdown-timer)
        (cancel-timer +lsp--deferred-shutdown-timer))
      (setq +lsp--deferred-shutdown-timer
            (run-at-time
             (if (numberp +lsp-defer-shutdown) +lsp-defer-shutdown 3)
             nil (lambda (workspace)
                   (with-lsp-workspace workspace
                     (unless (lsp--workspace-buffers workspace)
                       (let ((lsp-restart 'ignore))
                         (funcall orig-fn))
                       (+lsp-optimization-mode -1))))
             lsp--cur-workspace))))

  (defadvice! +lsp-dont-prompt-to-install-servers-maybe-a (orig-fn &rest args)
    :around #'lsp
    (when (buffer-file-name)
      (require 'lsp-mode)
      (lsp--require-packages)
      (if (or (lsp--filter-clients
               (-andfn #'lsp--matching-clients?
                       #'lsp--server-binary-present?))
              (not (memq +lsp-prompt-to-install-server '(nil quiet))))
          (apply orig-fn args)
        ;; HACK `lsp--message' overrides `inhibit-message', so use `quiet!'
        (let ((doom-debug-p
               (or doom-debug-p
                   (not (eq +lsp-prompt-to-install-server 'quiet)))))
          (doom-shut-up-a #'lsp--info "No language server available for %S"
                          major-mode)))))

  (when (featurep! :ui modeline +light)
    (defvar-local lsp-modeline-icon nil)

    (add-hook! '(lsp-before-initialize-hook
                 lsp-after-initialize-hook
                 lsp-after-uninitialized-functions
                 lsp-before-open-hook
                 lsp-after-open-hook)
      (defun +lsp-update-modeline (&rest _)
        "Update modeline with lsp state."
        (let* ((workspaces (lsp-workspaces))
               (face (if workspaces 'success 'warning))
               (label (if workspaces "LSP Connected" "LSP Disconnected")))
          (setq lsp-modeline-icon (concat
                                   " "
                                   (+modeline-format-icon 'faicon "rocket" "" face label -0.0575)
                                   " "))
          (add-to-list 'global-mode-string
                       '(t (:eval lsp-modeline-icon))
                       'append))))))


(use-package! lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :init
  (defadvice! +lsp--use-hook-instead-a (orig-fn &rest args)
    "Change `lsp--auto-configure' to not force `lsp-ui-mode' on us. Using a hook
instead is more sensible."
    :around #'lsp--auto-configure
    (letf! ((#'lsp-ui-mode #'ignore))
      (apply orig-fn args)))

  :config
  (when (featurep! +peek)
    (set-lookup-handlers! 'lsp-ui-mode
      :definition 'lsp-ui-peek-find-definitions
      :implementations 'lsp-ui-peek-find-implementation
      :references 'lsp-ui-peek-find-references
      :async t))

  (setq lsp-ui-peek-enable (featurep! +peek)
        lsp-ui-doc-max-height 8
        lsp-ui-doc-max-width 35
        lsp-ui-doc-show-with-mouse nil  ; don't disappear on mouseover
        lsp-ui-doc-position 'at-point
        lsp-ui-sideline-ignore-duplicate t
        ;; Don't show symbol definitions in the sideline. They are pretty noisy,
        ;; and there is a bug preventing Flycheck errors from being shown (the
        ;; errors flash briefly and then disappear).
        lsp-ui-sideline-show-hover nil
        ;; Re-enable icon scaling (it's disabled by default upstream for Emacs
        ;; 26.x compatibility; see emacs-lsp/lsp-ui#573)
        lsp-ui-sideline-actions-icon lsp-ui-sideline-actions-icon-default
        ;; REVIEW Temporarily disabled, due to immense slowness on every
        ;;        keypress. See emacs-lsp/lsp-ui#613
        lsp-ui-doc-enable nil)

  (map! :map lsp-ui-peek-mode-map
        "j"   #'lsp-ui-peek--select-next
        "k"   #'lsp-ui-peek--select-prev
        "C-k" #'lsp-ui-peek--select-prev-file
        "C-j" #'lsp-ui-peek--select-next-file))


(use-package! helm-lsp
  :when (featurep! :completion helm)
  :commands helm-lsp-workspace-symbol helm-lsp-global-workspace-symbol)


(use-package! lsp-ivy
  :when (featurep! :completion ivy)
  :commands lsp-ivy-workspace-symbol lsp-ivy-global-workspace-symbol)

(use-package! consult-lsp
  :when (featurep! :completion consult)
  :defer t)
