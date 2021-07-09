;;; input/layout/+bepo.el -*- lexical-binding: t; -*-

(defvar +layout-bepo-cr-rotation-style 'ergodis
  "Modify this variable in your $DOOMDIR/init.el
Style of binding rotation for the cr keys.
If 'ergodis, then the module maps the old 'c' bindings to 'l' and the old 'r' to 'h', as
the 'change' function is used more often and 'l' is easier to reach than 'h' in bépo.

If 'strict, the module does a normal swap and 'c' bindings go to 'h', 'r' bindings go to 'l'.

In all cases, 'h' functions go to 'c' and 'l' ones go to 'r' so the navigation keys still feel vim-like.")

;; Highlight non breaking spaces as error in prog modes only
;; REVIEW `nobreak-char-display' is defined in xdisp.c; will that work in non-X
;;        builds? From early observations in sway+pgtk, it does not.
(setq nobreak-char-display t)
(set-face-attribute 'nobreak-space nil :underline t)


;;
;;; Initializers

;; TODO Separate each package into their own hook, so users can
;;      enable/disable/add their own per-package remappings.

(defun +layout-remap-keys-for-bepo-h ()
  (setq avy-keys '(?a ?u ?i ?e ?, ?c ?t ?s ?r ?n)
        lispy-avy-keys '(?a ?u ?i ?e ?, ?c ?t ?s ?r ?n ?m ?b ?é ?p ?o ?è ?v ?d ?l ?j ?z))

  ;; :ui window-select settings, ignoring +numbers flag for now
  (after! ace-window
    (setq aw-keys '(?a ?u ?i ?e ?, ?c ?t ?s ?r ?n)))
  (after! switch-window
    (setq switch-window-shortcut-style 'qwerty
          switch-window-qwerty-shortcuts '("a" "u" "i" "e" "," "c" "t" "s" "r")))

  (map! "C-é" 'evil-window-map)
  (map! :leader
        :desc "Window"                     "é"  evil-window-map
        (:when (featurep! :ui popup)
         :desc "Toggle last popup"         "#"  #'+popup/toggle)
        (:when (featurep! :ui workspaces)
         :desc "Switch buffer"             "«"  #'switch-to-buffer)
        :desc "Switch to last buffer"      "$"  #'evil-switch-to-windows-last-buffer
        (:when (featurep! :ui workspaces)
         (:prefix-map ("TAB" . "workspace")
          :desc "Switch to last workspace" "$"  #'+workspace/other
          :desc "Next workspace"           ")"  #'+workspace/switch-right
          :desc "Previous workspace"       "("  #'+workspace/switch-left))
        (:prefix-map ("b" . "buffer")
         :desc "Previous buffer"           "("  #'previous-buffer
         :desc "Next buffer"               ")"  #'next-buffer)
        (:prefix-map ("c" . "code")
         :desc "Jump to documentation"     "S"  #'+lookup/documentation)
        (:prefix-map ("g" . "git")
         (:when (featurep! :ui vc-gutter)
          :desc "Jump to next hunk"        ")"  #'git-gutter:next-hunk
          :desc "Jump to previous hunk"    "("  #'git-gutter:previous-hunk))
        (:prefix-map ("p" . "project")
         :desc "Browse other project"      "»"  #'doom/browse-in-other-project)))

(defun +layout-remap-evil-keys-for-bepo-h ()
  ;; "ts" would be a little too common for an evil escape sequence
  (setq evil-escape-key-sequence "gq")
  (setq evil-markdown-movement-bindings '((up . "s")
                                          (down . "t")
                                          (left . "c")
                                          (right . "r"))
        evil-org-movement-bindings '((up . "s")
                                     (down . "t")
                                     (left . "c")
                                     (right . "r")))
  (+layout-bepo-rotate-ts-bare-keymap '(read-expression-map))
  (+layout-bepo-rotate-bare-keymap '(evil-window-map) +layout-bepo-cr-rotation-style)
  (+layout-bepo-rotate-evil-keymap +layout-bepo-cr-rotation-style)
  ;; Remap the visual-mode-map bindings if necessary
  ;; See https://github.com/emacs-evil/evil/blob/7d00c23496c25a66f90ac7a6a354b1c7f9498162/evil-integration.el#L478-L501
  ;; Using +layout-bepo-rotate-keymaps is impossible because `evil-define-minor-mode-key' doesn't
  ;; provide an actual symbol to design the new keymap with, and instead stuff the keymap in
  ;; an auxiliary-auxiliary `minor-mode-map-alist'-like variable.
  (after! evil-integration
    (when evil-respect-visual-line-mode
      (map! :map visual-line-mode-map
            :m "t"  #'evil-next-visual-line
            ;; _Not_ remapping gj and gk because they aren't remapped
            ;; consistently across all Emacs.
            :m "s"  #'evil-previous-visual-line
            :m "È"  #'evil-beginning-of-visual-line
            :m "gÈ" #'evil-beginning-of-line
            :m "$"  #'evil-end-of-visual-line
            :m "g$" #'evil-end-of-line
            :m "V"  #'evil-visual-screen-line)))

  (map! :i "C-t" #'+default-newline
        (:when (featurep! :editor multiple-cursors)
         :prefix "gz"
         :nv "t"   #'evil-mc-make-cursor-move-next-line
         :nv "s"   #'evil-mc-make-cursor-move-prev-line
         ;; The old toggle mapping (t) is made available both on "T" for
         ;; mnemonics and "j" as a "classic" rotation
         :nv "T"   #'+multiple-cursors/evil-mc-toggle-cursors
         :nv "j"   #'+multiple-cursors/evil-mc-toggle-cursors)
        (:when (featurep! :ui popup)
         :n "C-$"  #'+popup/toggle
         :n "C-#"  #'+popup/raise))
  (after! treemacs
    (+layout-bepo-rotate-ts-bare-keymap '(evil-treemacs-state-map)))
  (after! (:or helm ivy selectrum icomplete)
    (+layout-bepo-rotate-keymaps
     '(minibuffer-local-map
       minibuffer-local-ns-map
       minibuffer-local-completion-map
       minibuffer-local-must-match-map
       minibuffer-local-isearch-map
       read-expression-map))
    (+layout-bepo-rotate-bare-keymap
     '(minibuffer-local-map
       minibuffer-local-ns-map
       minibuffer-local-completion-map
       minibuffer-local-must-match-map
       minibuffer-local-isearch-map
       read-expression-map)
     +layout-bepo-cr-rotation-style))
  (after! ivy
    (+layout-bepo-rotate-bare-keymap '(ivy-minibuffer-map ivy-switch-buffer-map) +layout-bepo-cr-rotation-style)
    (+layout-bepo-rotate-keymaps '(ivy-minibuffer-map ivy-switch-buffer-map)))
  (after! swiper
    (map! :map swiper-map "C-s" nil))
  (after! helm
    (+layout-bepo-rotate-bare-keymap '(helm-map) +layout-bepo-cr-rotation-style)
    (+layout-bepo-rotate-keymaps '(helm-map)))
  (after! helm-rg
    (+layout-bepo-rotate-bare-keymap '(helm-rg-map) +layout-bepo-cr-rotation-style)
    (+layout-bepo-rotate-keymaps '(helm-rg-map)))
  (after! helm-files
    (+layout-bepo-rotate-bare-keymap '(helm-read-file-map) +layout-bepo-cr-rotation-style)
    (+layout-bepo-rotate-keymaps '(helm-read-file-map)))
  (after! company
    (+layout-bepo-rotate-bare-keymap '(company-active-map company-search-map) +layout-bepo-cr-rotation-style))
  (after! evil-snipe
    (+layout-bepo-rotate-keymaps
     '(evil-snipe-local-mode-map evil-snipe-override-local-mode-map)))
  (after! eshell
    (add-hook 'eshell-first-time-mode-hook (lambda () (+layout-bepo-rotate-keymaps '(eshell-mode-map))) 99))
  (after! lispyville
    ;; <> en direct
    (general-translate-key '(normal motion) 'lispyville-mode-map
      "«" "<"
      "»" ">"))
  (after! lsp-ui
    (+layout-bepo-rotate-ts-bare-keymap '(lsp-ui-peek-mode-map)))
  (after! org
    (defadvice! doom-bepo--org-completing-read (&rest args)
      "Completing-read with SPACE being a normal character, and C-c mapping left alone."
      :override #'org-completing-read
      (let ((enable-recursive-minibuffers t)
            (minibuffer-local-completion-map
             (copy-keymap minibuffer-local-completion-map)))
        (define-key minibuffer-local-completion-map " " 'self-insert-command)
        (define-key minibuffer-local-completion-map "?" 'self-insert-command)
        (define-key minibuffer-local-completion-map
          (cond
           ((eq +layout-bepo-cr-rotation-style 'ergodis)
            (kbd "C-l !"))
           (t
            (kbd "C-h !")))
          'org-time-stamp-inactive)
        (apply #'completing-read args)))
    ;; Finalizing an Org-capture become `C-l C-c` (or `C-r C-c`) on top of `ZZ`
    (+layout-bepo-rotate-bare-keymap '(org-capture-mode-map) +layout-bepo-cr-rotation-style))
  (after! (evil org evil-org)
    ;; FIXME: This map! call is being interpreted before the
    ;;   map! call in (use-package! evil-org :config) in modules/lang/org/config.el
    ;;   Therefore, this map! needs to be reevaluated to have effect.
    ;;   Need to find a way to call the code below after the :config block
    ;;   in :lang org code

    ;; Direct access for "unimpaired" like improvements
    (map! :map evil-org-mode-map
          ;; evil-org-movement bindings having "c" and "r" means
          ;; C-r gets mapped to `org-shiftright' in normal and insert state.
          ;; C-c gets mapped to `org-shiftleft' in normal and insert state.
          :ni "C-r" nil
          :ni "C-c" nil
          :ni "C-»" #'org-shiftright
          :ni "C-«" #'org-shiftleft
          :m ")" nil
          :m "(" nil
          :m "]" #'evil-org-forward-sentence
          :m "[" #'evil-org-backward-sentence
          :m ")h" #'org-forward-heading-same-level
          :m "(h" #'org-backward-heading-same-level
          :m ")l" #'org-next-link
          :m "(l" #'org-previous-link
          :m ")c" #'org-babel-next-src-block
          :m "(c" #'org-babel-previous-src-block))
  (after! (evil org evil-org-agenda)
    (+layout-bepo-rotate-bare-keymap '(org-agenda-keymap) +layout-bepo-cr-rotation-style)
    (+layout-bepo-rotate-keymaps '(evil-org-agenda-mode-map)))
  (after! notmuch
    ;; Without this, "s" is mapped to `notmuch-search' and takes precedence over
    ;; the evil command to go up one line
    (map! :map notmuch-common-keymap :n "s" nil)
    (map! :map notmuch-common-keymap "s" nil))
  (after! (evil info)
    ;; Without this, "s" stays mapped to 'Info-search (in the "global"
    ;; `Info-mode-map') and takes precedence over the evil command to go up one
    ;; line (remapped in `Info-mode-normal-state-map').  Same for "t" that is
    ;; `Info-top-node' in the "global" `Info-mode-map'
    (map! :map Info-mode-map
          "s" nil
          "t" nil))
  (after! (evil magit)
    (+layout-bepo-rotate-ts-bare-keymap
     '(magit-mode-map
       magit-diff-section-base-map
       magit-staged-section-map
       magit-unstaged-section-map
       magit-untracked-section-map))
    ;; Without this, "s" is mapped to 'magit-delete-thing (the old "k" for "kill") and
    ;; takes precedence over the evil command to go up one line
    ;; :nv doesn't work on this, needs to be the bare map.
    ;; This is the output of `describe-function 'magit-delete-thing` when we add :nv or :nvm
    ;; Key Bindings
    ;;   evil-collection-magit-mode-map-backup-map <normal-state> x
    ;;   evil-collection-magit-mode-map-backup-map <visual-state> x
    ;;   evil-collection-magit-mode-map-backup-map k
    ;;   evil-collection-magit-mode-map-normal-state-backup-map x
    ;;   evil-collection-magit-mode-map-visual-state-backup-map x
    ;;   magit-mode-map <normal-state> x
    ;;   magit-mode-map <visual-state> x
    ;;   magit-mode-map s
    (map! :map magit-mode-map "s" nil)
    ;; Even though magit bindings are part of evil-collection now, the hook only
    ;; runs on `evil-collection-magit-maps', which is way to short to cover all
    ;; usages. The hook is run manually on other maps
    ;; NOTE `magit-mode-map' is last because other keymaps inherit from it.
    ;;      Therefore to prevent a "double rotation" issue, `magit-mode-map' is
    ;;      changed last.
    (+layout-bepo-rotate-keymaps
     '(magit-cherry-mode-map
       magit-blob-mode-map
       magit-diff-mode-map
       magit-log-mode-map
       magit-log-select-mode-map
       magit-reflog-mode-map
       magit-status-mode-map
       magit-log-read-revs-map
       magit-process-mode-map
       magit-refs-mode-map
       magit-mode-map)))
  (after! evil-easymotion
    ;; Use "gé" instead of default "gs" to avoid conflicts w/org-mode later
    (evilem-default-keybindings "gé")
    (+layout-bepo-rotate-bare-keymap '(evilem-map) +layout-bepo-cr-rotation-style)))


;;
;;; Bootstrap

(+layout-remap-keys-for-bepo-h)
(when (featurep! :editor evil)
  (+layout-remap-evil-keys-for-bepo-h)
  (add-hook! 'evil-collection-setup-hook
    (defun +layout-bepo-rotate-evil-collection-keymap (_mode mode-keymaps &rest _rest)
      (+layout-bepo-rotate-keymaps mode-keymaps))))
