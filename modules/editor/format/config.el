;;; editor/format/config.el -*- lexical-binding: t; -*-

(defvar +format-on-save-enabled-modes
  '(not emacs-lisp-mode    ; elisp's mechanisms are good enough
        sql-mode           ; sqlformat is currently broken
        tex-mode           ; latexindent is broken
        latex-mode
        org-msg-edit-mode) ; doesn't need a formatter
  "A list of major modes in which to reformat the buffer upon saving.

If this list begins with `not', then it negates the list.
If it is `t', it is enabled in all modes.
If nil, it is disabled in all modes, the same as if the +onsave flag wasn't
  used at all.

Irrelevant if you do not have the +onsave flag enabled for this module.")

(defvar +format-preserve-indentation t
  "If non-nil, the leading indentation is preserved when formatting the whole
buffer. This is particularly useful for partials.

Indentation is always preserved when formatting regions.")

(defvar-local +format-with nil
  "Set this to explicitly use a certain formatter for the current buffer.")

(defvar +format-with-lsp t
  "If non-nil, format with LSP formatter if it's available.

This can be set buffer-locally with `setq-hook!' to disable LSP formatting in
select buffers.")


;;
;;; Bootstrap

(defun +format-enable-on-save-maybe-h ()
  "Enable formatting on save in certain major modes.

This is controlled by `+format-on-save-enabled-modes'."
  (cond ((eq major-mode 'fundamental-mode))
        ((string-prefix-p " " (buffer-name)))
        ((booleanp +format-on-save-enabled-modes)
         +format-on-save-enabled-modes)
        ((if (eq (car-safe +format-on-save-enabled-modes) 'not)
             (memq major-mode (cdr +format-on-save-enabled-modes))
           (not (memq major-mode +format-on-save-enabled-modes))))
        ((not (require 'format-all nil t)))
        ((format-all-mode +1))))

(when (featurep! +onsave)
  (add-hook 'after-change-major-mode-hook #'+format-enable-on-save-maybe-h))


;;
;;; Hacks

;; Allow a specific formatter to be used by setting `+format-with', either
;; buffer-locally or let-bound.
(advice-add #'format-all--probe :around #'+format-probe-a)

;; Doom uses a modded `format-all-buffer', which
;;   1. Enables partial reformatting (while preserving leading indentation),
;;   2. Applies changes via RCS patch, line by line, to protect buffer markers
;;      and avoid any jarring cursor+window scrolling.
(advice-add #'format-all-buffer--with :override #'+format-buffer-a)
(advice-add #'format-all-buffer--from-hook :override #'+format-buffer-h)

;; format-all-mode "helpfully" raises an error when it doesn't know how to
;; format a buffer.
(add-to-list 'debug-ignored-errors "^Don't know how to format ")

;; Don't pop up imposing warnings about missing formatters, but still log it in
;; to *Messages*.
(defadvice! +format--all-buffer-from-hook-a (orig-fn &rest args)
  :around #'format-all-buffer--from-hook
  (letf! (defun format-all-buffer--with (formatter mode-result)
           (when (or (eq formatter 'lsp)
                     (eq formatter 'eglot)
                     (condition-case-unless-debug e
                         (format-all--formatter-executable formatter)
                       (error
                        (message "Warning: cannot reformat buffer because %S isn't installed"
                                 (gethash formatter format-all--executable-table))
                        nil)))
             (funcall format-all-buffer--with formatter mode-result)))
    (apply orig-fn args)))
