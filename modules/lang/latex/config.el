;;; lang/latex/config.el -*- lexical-binding: t; -*-

(defconst +latex-indent-item-continuation-offset 'align
  "Level to indent continuation of enumeration-type environments.

i.e. This affects \\item, \\enumerate, and \\description.

Set this to `align' for:

  \\item lines aligned
         like this.

Set to `auto' for continuation lines to be offset by `LaTeX-indent-line':

  \\item lines aligned
    like this, assuming LaTeX-indent-line == 2

Any other fixed integer will be added to `LaTeX-item-indent' and the current
indentation level.

Set this to `nil' to disable all this behavior.

You'll need to adjust `LaTeX-item-indent' to control indentation of \\item
itself.")

(defvar +latex-enable-unicode-math nil
  "If non-nil, use `company-math-symbols-unicode' backend in LaTeX-mode,
enabling unicode symbols in math regions. This requires the unicode-math latex
package to be installed.")

(defvar +latex-viewers '(skim evince sumatrapdf zathura okular pdf-tools)
  "A list of enabled latex viewers to use, in this order. If they don't exist,
they will be ignored. Recognized viewers are skim, evince, sumatrapdf, zathura,
okular and pdf-tools.

If no viewers are found, `latex-preview-pane' is used.")

;;
(defvar +latex--company-backends nil)


;;
;; Packages

(add-to-list 'auto-mode-alist '("\\.tex\\'" . LaTeX-mode))

(setq TeX-parse-self t ; parse on load
      TeX-auto-save t  ; parse on save
      ;; use hidden dirs for auctex files
      TeX-auto-local ".auctex-auto"
      TeX-style-local ".auctex-style"
      TeX-source-correlate-mode t
      TeX-source-correlate-method 'synctex
      ;; don't start the emacs server when correlating sources
      TeX-source-correlate-start-server nil
      ;; automatically insert braces after sub/superscript in math mode
      TeX-electric-sub-and-superscript t
      ;; just save, dont ask me before each compilation
      TeX-save-query nil)


(after! tex
  ;; fontify common latex commands
  (load! "+fontification")
  ;; select viewer
  (load! "+viewers")
  ;; do not prompt for master
  (setq-default TeX-master t)
  ;; set-up chktex
  (setcar (cdr (assoc "Check" TeX-command-list)) "chktex -v6 -H %s")
  (setq-hook! 'TeX-mode-hook
    ;; tell emacs how to parse tex files
    ispell-parser 'tex
    ;; Don't auto-fill in math blocks
    fill-nobreak-predicate (cons #'texmathp fill-nobreak-predicate))
  ;; Enable word wrapping
  (add-hook 'TeX-mode-hook #'visual-line-mode)
  ;; Enable rainbow mode after applying styles to the buffer
  (add-hook 'TeX-update-style-hook #'rainbow-delimiters-mode)
  ;; display output of latex commands in popup
  (set-popup-rules! '((" output\\*$" :size 15)
                      ("^\\*TeX \\(?:Help\\|errors\\)"
                       :size 0.3 :select t :ttl nil)))
  (after! smartparens-latex
    (let ((modes '(tex-mode plain-tex-mode latex-mode LaTeX-mode)))
      ;; All these excess pairs dramatically slow down typing in latex buffers,
      ;; so we remove them. Let snippets do their job.
      (dolist (open '("\\left(" "\\left[" "\\left\\{" "\\left|"
                      "\\bigl(" "\\biggl(" "\\Bigl(" "\\Biggl(" "\\bigl["
                      "\\biggl[" "\\Bigl[" "\\Biggl[" "\\bigl\\{" "\\biggl\\{"
                      "\\Bigl\\{" "\\Biggl\\{"
                      "\\lfloor" "\\lceil" "\\langle"
                      "\\lVert" "\\lvert" "`"))
        (sp-local-pair modes open nil :actions :rem))
      ;; And tweak these so that users can decide whether they want use latex
      ;; quotes or not, via `+latex-enable-plain-double-quotes'
      (sp-local-pair modes "``" nil :unless '(:add sp-in-math-p))))
  ;; Hook lsp if enabled
  (when (featurep! +lsp)
    (add-hook! '(tex-mode-local-vars-hook
                 latex-mode-local-vars-hook)
               #'lsp!))
  (map! :localleader
        :map latex-mode-map
        :desc "View" "v" #'TeX-view)
  (map! :after latex
        :map LaTeX-mode-map
        :localleader
        :desc "View" "v" #'TeX-view))


(use-package! tex-fold
  :when (featurep! +fold)
  :hook (TeX-mode . TeX-fold-buffer)
  :hook (TeX-mode . TeX-fold-mode)
  :config
  ;; Fold after all auctex macro insertions
  (advice-add #'TeX-insert-macro :after #'+latex-fold-last-macro-a)
  ;; Fold after cdlatex macro insertions
  (advice-add #'cdlatex-math-symbol :after #'+latex-fold-last-macro-a)
  (advice-add #'cdlatex-math-modify :after #'+latex-fold-last-macro-a)
  ;; Fold after snippets
  (when (featurep! :editor snippets)
    (add-hook! 'TeX-fold-mode-hook
      (defun +latex-fold-snippet-contents-h ()
        (add-hook! 'yas-after-exit-snippet-hook :local
          (when (and yas-snippet-beg yas-snippet-end)
            (TeX-fold-region yas-snippet-beg yas-snippet-end))))))

  (add-hook! 'mixed-pitch-mode-hook
    (defun +latex-fold-set-variable-pitch-h ()
      "Fix folded things invariably getting fixed pitch when using mixed-pitch.
Math faces should stay fixed by the mixed-pitch blacklist, this is mostly for
\\section etc."
      (when mixed-pitch-mode
        ;; Adding to this list makes mixed-pitch clean the face remaps after us
        (add-to-list 'mixed-pitch-fixed-cookie
                     (face-remap-add-relative
                      'TeX-fold-folded-face
                      :family (face-attribute 'variable-pitch :family)
                      :height (face-attribute 'variable-pitch :height))))))

  (map! :map TeX-fold-mode-map
        :localleader
        :desc "Fold paragraph"   "f"   #'TeX-fold-paragraph
        :desc "Unfold paragraph" "F"   #'TeX-fold-clearout-paragraph
        :desc "Unfold buffer"    "C-f" #'TeX-fold-clearout-buffer))


(after! latex
  (setq LaTeX-section-hook ; Add the toc entry to the sectioning hooks.
        '(LaTeX-section-heading
          LaTeX-section-title
          LaTeX-section-toc
          LaTeX-section-section
          LaTeX-section-label)
        LaTeX-fill-break-at-separators nil
        LaTeX-item-indent 0)
  (when +latex--company-backends
    (set-company-backend! 'latex-mode +latex--company-backends))

  ;; Provide proper indentation for LaTeX "itemize","enumerate", and
  ;; "description" environments. See
  ;; http://emacs.stackexchange.com/questions/3083/how-to-indent-items-in-latex-auctex-itemize-environments
  ;; Set `+latex-indent-item-continuation-offset' to 0 to disable this
  (dolist (env '("itemize" "enumerate" "description"))
    (add-to-list 'LaTeX-indent-environment-list `(,env +latex-indent-item-fn)))

  ;; Fix #1849: allow fill-paragraph in itemize/enumerate
  (defadvice! +latex--re-indent-itemize-and-enumerate-a (orig-fn &rest args)
    :around #'LaTeX-fill-region-as-para-do
    (let ((LaTeX-indent-environment-list
           (append LaTeX-indent-environment-list
                   '(("itemize"   +latex-indent-item-fn)
                     ("enumerate" +latex-indent-item-fn)))))
      (apply orig-fn args)))
  (defadvice! +latex--dont-indent-itemize-and-enumerate-a (orig-fn &rest args)
    :around #'LaTeX-fill-region-as-paragraph
    (let ((LaTeX-indent-environment-list LaTeX-indent-environment-list))
      (delq! "itemize" LaTeX-indent-environment-list 'assoc)
      (delq! "enumerate" LaTeX-indent-environment-list 'assoc)
      (apply orig-fn args))))


(use-package! preview
  :hook (LaTeX-mode . LaTeX-preview-setup)
  :config
  (setq-default preview-scale 1.4
                preview-scale-function
                (lambda () (* (/ 10.0 (preview-document-pt)) preview-scale)))
  ;; Don't cache preamble, it creates issues with synctex. Let users enable
  ;; caching if they have compilation times that long.
  (setq preview-auto-cache-preamble nil)
  (map! :map LaTeX-mode-map
        :localleader
        :desc "Preview" "p" #'preview-at-point
        :desc "Unpreview" "P" #'preview-clearout-at-point))


(use-package! cdlatex
  :when (featurep! +cdlatex)
  :hook (LaTeX-mode . cdlatex-mode)
  :hook (org-mode . org-cdlatex-mode)
  :config
  ;; Use \( ... \) instead of $ ... $
  (setq cdlatex-use-dollar-to-ensure-math nil)
  ;; Disabling keys that have overlapping functionality with other parts of Doom
  (map! :map cdlatex-mode-map
        ;; smartparens takes care of inserting closing delimiters, and if you
        ;; don't use smartparens you probably won't want these also.
        "$" nil
        "(" nil
        "{" nil
        "[" nil
        "|" nil
        "<" nil
        ;; TAB is used for cdlatex's snippets and navigation. But we have
        ;; yasnippet for that.
        (:when (featurep! :editor snippets)
          "TAB" nil)
        ;; AUCTeX takes care of auto-inserting {} on _^ if you want, with
        ;; `TeX-electric-sub-and-superscript'
        "^" nil
        "_" nil
        ;; AUCTeX already provides this with `LaTeX-insert-item'
        [(control return)] nil))


;; Nicely indent lines that have wrapped when visual line mode is activated
(use-package! adaptive-wrap
  :hook (LaTeX-mode . adaptive-wrap-prefix-mode)
  :init (setq-default adaptive-wrap-extra-indent 0))


(use-package! auctex-latexmk
  :when (featurep! +latexmk)
  :after latex
  :init
  ;; Pass the -pdf flag when TeX-PDF-mode is active
  (setq auctex-latexmk-inherit-TeX-PDF-mode t)
  ;; Set LatexMk as the default
  (setq-hook! LaTeX-mode TeX-command-default "LatexMk")
  :config
  ;; Add latexmk as a TeX target
  (auctex-latexmk-setup))


(use-package! evil-tex
  :when (featurep! :editor evil +everywhere)
  :hook (LaTeX-mode . evil-tex-mode))


(use-package! company-auctex
  :when (featurep! :completion company)
  :defer t
  :init
  (add-to-list '+latex--company-backends #'company-auctex-environments nil #'eq)
  (add-to-list '+latex--company-backends #'company-auctex-macros nil #'eq))


(use-package! company-math
  :when (featurep! :completion company)
  :defer t
  :init
  (add-to-list '+latex--company-backends #'+latex-symbols-company-backend nil #'eq))


;; bibtex + reftex
(load! "+ref")
