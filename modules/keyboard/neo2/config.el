

;;
;;; Global keybindings

(map!
 :m "C-u"  #'evil-scroll-line-up
 :m "C-ü"  #'evil-scroll-line-down)


;;
;;; Module keybindings

(map!
 (:when (featurep! :editor evil)
   (:after evil-snipe
     (:map evil-snipe-parent-transient-map
       "," nil
       "," #'evil-snipe-repeat
       "–" #'evil-snipe-repeat-reverse))
   (:after evil-easymotion
     (:map evilem-map
       "a" #'evilem-motion-next-line
       "l" #'evilem-motion-previous-line
       "ga" #'evilem-motion-next-visual-line
       "gl" #'evilem-motion-previous-visual-line)))

 (:when (featurep! :lang latex)
   (:after latex
     (:map LaTeX-mode-map
       ;; Greek lower case letters
       "ξ" (λ! (self-insert-command "\\xi"))
       "λ" (λ! (insert "\\lambda"))
       "χ" (λ! (insert "\\chi"))
       "ω" (λ! (insert "\\omega"))
       "κ" (λ! (insert "\\kappa"))
       "ψ" (λ! (insert "\\psi"))
       "γ" (λ! (insert "\\gamma"))
       "φ" (λ! (insert "\\varphi"))
       "ϕ" (λ! (insert "\\phi"))
       "ς" (λ! (insert "\\varsigma"))
       "ι" (λ! (insert "\\iota"))
       "α" (λ! (insert "\\alpha"))
       "ε" (λ! (insert "\\varepsilon"))
       "σ" (λ! (insert "\\sigma"))
       "ν" (λ! (insert "\\nu"))
       "ρ" (λ! (insert "\\rho"))
       "τ" (λ! (insert "\\tau"))
       "δ" (λ! (insert "\\delta"))
       "υ" (λ! (insert "\\upsilon"))
       "ϵ" (λ! (insert "\\epsilon"))
       "η" (λ! (insert "\\eta"))
       "π" (λ! (insert "\\pi"))
       "ζ" (λ! (insert "\\zeta"))
       "β" (λ! (insert "\\beta"))
       "μ" (λ! (insert "\\mu"))
       "ϱ" (λ! (insert "\\varrho"))
       "ϑ" (λ! (insert "\\vartheta"))
       "θ" (λ! (insert "\\theta"))
       ;; Greek upper case letters
       "Ξ" (λ! (insert "\\Xi"))
       "Λ" (λ! (insert "\\Lambda"))
       "Ω" (λ! (insert "\\Omega"))
       "Ψ" (λ! (insert "\\Psi"))
       "Γ" (λ! (insert "\\Gamma"))
       "Φ" (λ! (insert "\\Phi"))
       "Δ" (λ! (insert "\\Delta"))
       "Θ" (λ! (insert "\\Theta"))
       ;; We treat these specially
       "Π" (λ! (when (featurep! :editor snippets)
                    (yas/insert-by-name "prod")
                    (insert "\\Pi")))
       "Σ" (λ! (when (featurep! :editor snippets)
                    (yas/insert-by-name "sum")
                    (insert "\\Sigma")))
       ;; Mathematical symbols
       "¬" (λ! (insert "\\neg"))
       "∨" (λ! (insert "\\lor"))
       "∧" (λ! (insert "\\land"))
       "⊥" (λ! (insert "\\bot"))
       "∡" (λ! (insert "\\measuredangle"))
       "∥" (λ! (insert "\\|"))
       "→" (λ! (insert "\\rightarrow"))
       "∞" (λ! (insert "\\infty"))
       "∝" (λ! (insert "\\propto"))
       "∅" (λ! (insert "\\emptyset"))
       "√" (λ! (insert "\\sqrt"))
       "ℂ" (λ! (insert "\\mathbb{C}"))
       "ℚ" (λ! (insert "\\mathbb{Q}"))
       "∘" (λ! (insert "\\circ"))
       "⊂" (λ! (insert "\\subset"))
       "∫" (λ! (when (featurep! :editor snippets)
                    (yas/insert-by-name "int")
                    (insert "\\int")))
       "∀" (λ! (insert "\\forall"))
       "∃" (λ! (insert "\\exists"))
       "∈" (λ! (insert "\\in"))
       "ℕ" (λ! (insert "\\mathbb{N}"))
       "ℝ" (λ! (insert "\\mathbb{R}"))
       "∂" (λ! (insert "\\partial"))
       "∇" (λ! (insert "\\nabla"))
       "∪" (λ! (insert "\\cup"))
       "∩" (λ! (insert "\\cap"))
       "ℵ" (λ! (insert "\\aleph"))
       "ℤ" (λ! (insert "\\mathbb{Z}"))
       "⇐" (λ! (insert "\\Leftarrow"))
       "⇔" (λ! (insert "\\Leftrightarrow"))
       "⇒" (λ! (insert "\\Rightarrow"))
       "↦" (λ! (insert "\\mapsto"))
       ;; Misc
       "¹" (λ! (insert "^1"))
       "²" (λ! (insert "^2"))
       "³" (λ! (insert "^3"))
       "₂" (λ! (insert "_2"))
       "₃" (λ! (insert "_3"))
       "›" (λ! (insert "\\guilsinglright"))
       "‹" (λ! (insert "\\guilsinglleft"))
       "¢" (λ! (insert "\\textcent"))
       "¥" (λ! (insert "\\textyen"))
       "‘" (λ! (insert "`"))
       "’" (λ! (insert "\'"))
       "ª" (λ! (insert "^a"))
       "º" (λ! (insert "^o"))
       "№" (λ! (insert "\\textnumero"))
       "·" (λ! (insert "\\cdot"))
       "£" (λ! (insert "\\pounds"))
       "¤" (λ! (insert "\\textcurrency"))
       "°" (λ! (insert "\\degree"))
       "§" (λ! (insert "\\S"))
       "ℓ" (λ! (insert "\\ell"))
       "»" (λ! (insert "\\guillemotright"))
       "«" (λ! (insert "\\guillemotleft"))
       "„" (λ! (insert ",,"))
       "“" (λ! (insert "``"))
       "”" (λ! (insert "\'\'"))
       "—" (λ! (insert "\\textemdash"))
       "…" (λ! (insert "\\dots"))
       "­" (λ! (insert "\\-"))
       ;; Number block
       "␣" (λ! (insert "\\textvisiblespace"))
       "♦" (λ! (insert "\\diamondsuit"))
       "♥" (λ! (insert "\\heartsuit"))
       "♠" (λ! (insert "\\spadesuit"))
       "♣" (λ! (insert "\\clubsuit"))
       "✔" (λ! (insert "\\checkmark"))
       "✘" (λ! (insert "\\xmark"))
       "†" (λ! (insert "\\Cross"))
       "↔" (λ! (insert "\\leftrightarrow"))
       "↓" (λ! (insert "\\downarrow"))
       "⇌" (λ! (insert "\\rightleftharpoons "))
       "←" (λ! (insert "\\leftarrow"))
       "→" (λ! (insert "\\rightarrow"))
       "↕" (λ! (insert "\\updownarrow"))
       "↑" (λ! (insert "\\uparrow"))
       "±" (λ! (insert "\\pm"))
       "÷" (λ! (insert "\\div"))
       "⋅" (λ! (insert "\\cdot"))
       "∓" (λ! (insert "\\mp"))
       "≠" (λ! (insert "\\neq"))
       "∕" (λ! (insert "\\-"))
       "×" (λ! (insert "\\times"))
       "∖" (λ! (insert "\\setminus"))
       "□" (λ! (insert "\\Box"))
       "″" (λ! (insert "^{\\prime\\prime}"))
       "⌊" (λ! (insert "\\lfloor"))
       "⋃" (λ! (when (featurep! :editor snippets)
                    (yas/insert-by-name "bigcup")
                    (insert "\\bigcup")))
       "⌋" (λ! (insert "\\rfloor"))
       "⊆" (λ! (insert "\\subseteq"))
       "⊷" (λ! (insert "\\imageof "))
       "⊇" (λ! (insert "\\supseteq"))
       "⌈" (λ! (insert "\\leftceil"))
       "⋂" (λ! (when (featurep! :editor snippets)
                    (yas/insert-by-name "bigcap")
                    (insert "\\bigcap")))
       "⌉" (λ! (insert "\\rightceil"))
       "∔" (λ! (insert "\\dotplus"))
       "≡" (λ! (insert "\\equiv"))
       "∣" (λ! (insert "\\bigm|"))
       "⊗" (λ! (insert "\\otimes"))
       "∸" (λ! (insert "\\dotdiv"))
       "‰" (λ! (insert "\\textperthousand"))
       "′" (λ! (insert "^{\\prime}"))
       "≤" (λ! (insert "\\leq"))
       "∪" (λ! (insert "\\cup"))
       "≥" (λ! (insert "\\req"))
       "⊂" (λ! (insert "\\subset"))
       "⊶" (λ! (insert "\\original"))
       "⊃" (λ! (insert "\\supset"))
       "≪" (λ! (insert "\\ll"))
       "∩" (λ! (insert "\\cap"))
       "≫" (λ! (insert "\\rr"))
       "⊕" (λ! (insert "\\oplus"))
       "≈" (λ! (insert "\\approx"))
       "⌀" (λ! (insert "\\emptyset"))
       "⊙" (λ! (insert "\\odot"))
       "⊖" (λ! (insert "\\ominus")))))

 (:when (featurep! :lang org)
   (:after org
     (:map org-mode-map
       "M-<up>"        #'org-previous-visible-heading
       "M-<down>"      #'org-next-visible-heading))

   (:after evil-org
     (setq evil-org-movement-bindings
           '((up .    "l")
             (down .  "a")
             (left .  "i")
             (right . "e")))
     (:map evil-org-mode-map
       :ni "M-l"           #'org-metaup
       :ni "M-i"           #'org-metaleft
       :ni "M-a"           #'org-metadown
       :ni "M-e"           #'org-metaright
       :ni "M-l"           #'org-metaup
       :ni "M-I"           #'org-shiftmetaleft
       :ni "M-A"           #'org-shiftmetadown
       :ni "M-E"           #'org-shiftmetaright
       :ni "M-L"           #'org-shiftmetaup)))

 ;;; :tools
 (:when (featurep! :tools magit)
   (:after magit
     (:map git-rebase-mode-map
       "gl"  #'git-rebase-move-line-up
       "ga"  #'git-rebase-move-line-down
       "M-l" #'git-rebase-move-line-up
       "M-a" #'git-rebase-move-line-down)))

 (:when (featurep! :tools pass)
   (:after pass
     (:map pass-mode-map
       "a" #'pass-next-entry
       "l" #'pass-prev-entry
       "A" #'pass-next-directory
       "L" #'pass-prev-directory
       "j" #'pass-goto-entry)))

 (:when (featurep! :tools pdf)
   (:after pdf-view
     (:map pdf-view-mode-map
       :n "<left>"  #'image-backward-hscroll
       :n "<right>" #'image-forward-hscroll
       :n "C-a"     #'pdf-view-next-page-command
       :n "C-l"     #'pdf-view-previous-page-command)))

;;; :ui
 (:when (featurep! :ui neotree)
   (:after neotree
     (:map neotree-mode-map
       ;; :n "n"   #'neotree-next-line
       ;; :n "p"   #'neotree-previous-line
       :n "<left>"   #'+neotree/collapse-or-up
       :n "<right>"   #'+neotree/expand-or-open
       :n "n"   #'neotree-select-next-sibling-node
       :n "p"   #'neotree-select-previous-sibling-node
       :n "i"   #'neotree-select-up-node
       :n "e"   #'neotree-select-down-node)))

 (:when (featurep! :ui treemacs)
   (:when (featurep! :editor evil +everywhere)
     (:after treemacs-evil              ;TODO
       (:map evil-treemacs-state-map
         "j"       nil
         "l"       nil
         "l"       #'treemacs-root-up
         "a"       #'treemacs-root-down
         "M-l"     #'treemacs-previous-neighbour
         "M-a"     #'treemacs-next-neighbour
         "<left>"  #'treemacs-left-action
         "<right>" #'treemacs-RET-action)
       (:map treemacs-mode-map
         "l" nil))))

 (:when (featurep! :ui window-select)
   (:after avy
     (setq avy-keys '(?u ?i ?a ?e ?n ?r ?t ?d))))

 ;;; :email
 (:when (featurep! :email mu4e)
   (:after mu4e-headers
     (:map (mu4e-headers-mode-map mu4e-view-mode-map)
       :n "C-a" #'mu4e-view-headers-next
       :n "C-l" #'mu4e-view-headers-prev
       :n "C-i" #'mu4e-headers-query-prev
       :n "C-e" #'mu4e-headers-query-next)))

 ;;; :app
 (:when (featurep! :app calendar)
   (:after calfw
     (:map cfw:calendar-mode-map
       "M-e" #'cfw:navi-next-day-command
       "M-i" #'cfw:navi-previous-day-command
       "M-l" #'cfw:navi-previous-week-command
       "M-a" #'cfw:navi-next-week-command
       "<up>"    #'evil-previous-visual-line
       "<down>"  #'evil-next-visual-line
       "<left>"  #'evil-backward-char
       "<right>" #'evil-forward-char))))


;;
;;; <leader>

(map! :leader
      :desc "Switch to last buffer"    "(" #'evil-switch-to-windows-last-buffer
      :desc "Switch to last window"    "[" #'evil-window-mru
      :desc "Switch to last workspace" "{" #'+workspace/other

      ;;; <leader> TAB --- workspace
      (:when (featurep! :ui workspaces)
        (:prefix "TAB"
          :desc "Switch to last workspace"  ","   #'+workspace/other   ;;'`' is a pain to type
          )))


;;
;;; Built-in packages

(map!
 (:map comint-mode-map
   "C-a" #'comint-next-prompt
   "C-l" #'comint-previous-prompt)

 (:map Info-mode-map
   "C-a"  #'Info-next-preorder
   "C-l"  #'Info-last-preorder))


(defun treemacs-left-action (&optional arg)
  (interactive "P")
  (-when-let (state (treemacs--prop-at-point :state))
    (--if-let (cdr (assq state treemacs-left-actions-config))
        (progn
          (funcall it arg)
          (treemacs--evade-image))
      (treemacs-pulse-on-failure "No <left> action defined for node of type %s."
                                 (propertize (format "%s" state) 'face 'font-lock-type-face)))))

(defvar treemacs-left-actions-config
  '((root-node-open   . treemacs-toggle-node)
    (root-node-closed . treemacs-root-up)
    (dir-node-open    . treemacs-toggle-node)
    (dir-node-closed  . treemacs-collapse-parent-node)
    (file-node-open   . treemacs-collapse-parent-node)
    (file-node-closed . treemacs-collapse-parent-node)
    (tag-node-open    . treemacs-collapse-parent-node)
    (tag-node-closed  . treemacs-collapse-parent-node)
    (tag-node         . treemacs-collapse-parent-node)))

(defun yas/insert-by-name (name)
  (flet ((dummy-prompt
          (prompt choices &optional display-fn)
          (declare (ignore prompt))
          (or (find name choices :key display-fn :test #'string=)
              (throw 'notfound nil))))
    (let ((yas/prompt-functions '(dummy-prompt)))
      (catch 'notfound
        (yas/insert-snippet t)))))
