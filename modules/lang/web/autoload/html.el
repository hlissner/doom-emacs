;;; lang/web/autoload/html.el -*- lexical-binding: t; -*-

(defvar +web-entities-list
  [["&amp;" "&"] ["&nbsp;" " "] ["&ensp;" " "] ["&emsp;" " "] ["&thinsp;" " "]
   ["&lt;" "<"] ["&gt;" ">"]
   ["&rlm;" "‏"] ["&lrm;" "‎"] ["&zwj;" "‍"] ["&zwnj;" "‌"]
   ["&iexcl;" "¡"] ["&cent;" "¢"] ["&pound;" "£"] ["&curren;" "¤"] ["&yen;" "¥"]
   ["&brvbar;" "¦"] ["&sect;" "§"] ["&uml;" "¨"] ["&copy;" "©"] ["&ordf;" "ª"]
   ["&laquo;" "«"] ["&not;" "¬"] ["&shy;" "­"] ["&reg;" "®"] ["&macr;" "¯"]
   ["&deg;" "°"] ["&plusmn;" "±"] ["&sup2;" "²"] ["&sup3;" "³"] ["&acute;" "´"]
   ["&micro;" "µ"] ["&para;" "¶"] ["&middot;" "·"] ["&cedil;" "¸"] ["&sup1;" "¹"]
   ["&ordm;" "º"] ["&raquo;" "»"] ["&frac14;" "¼"] ["&frac12;" "½"]
   ["&frac34;" "¾"] ["&iquest;" "¿"] ["&Agrave;" "À"] ["&Aacute;" "Á"]
   ["&Acirc;" "Â"] ["&Atilde;" "Ã"] ["&Auml;" "Ä"] ["&Aring;" "Å"] ["&AElig;" "Æ"]
   ["&Ccedil;" "Ç"] ["&Egrave;" "È"] ["&Eacute;" "É"] ["&Ecirc;" "Ê"]
   ["&Euml;" "Ë"] ["&Igrave;" "Ì"] ["&Iacute;" "Í"] ["&Icirc;" "Î"] ["&Iuml;" "Ï"]
   ["&ETH;" "Ð"] ["&Ntilde;" "Ñ"] ["&Ograve;" "Ò"] ["&Oacute;" "Ó"]
   ["&Ocirc;" "Ô"] ["&Otilde;" "Õ"] ["&Ouml;" "Ö"] ["&times;" "×"] ["&Oslash;" "Ø"]
   ["&Ugrave;" "Ù"] ["&Uacute;" "Ú"] ["&Ucirc;" "Û"] ["&Uuml;" "Ü"]
   ["&Yacute;" "Ý"] ["&THORN;" "Þ"] ["&szlig;" "ß"] ["&agrave;" "à"] ["&aacute;" "á"]
   ["&acirc;" "â"] ["&atilde;" "ã"] ["&auml;" "ä"] ["&aring;" "å"]
   ["&aelig;" "æ"] ["&ccedil;" "ç"] ["&egrave;" "è"] ["&eacute;" "é"] ["&ecirc;" "ê"]
   ["&euml;" "ë"] ["&igrave;" "ì"] ["&iacute;" "í"] ["&icirc;" "î"]
   ["&iuml;" "ï"] ["&eth;" "ð"] ["&ntilde;" "ñ"] ["&ograve;" "ò"] ["&oacute;" "ó"]
   ["&ocirc;" "ô"] ["&otilde;" "õ"] ["&ouml;" "ö"] ["&divide;" "÷"] ["&oslash;" "ø"]
   ["&ugrave;" "ù"] ["&uacute;" "ú"] ["&ucirc;" "û"] ["&uuml;" "ü"] ["&yacute;" "ý"]
   ["&thorn;" "þ"] ["&yuml;" "ÿ"] ["&fnof;" "ƒ"] ["&Alpha;" "Α"] ["&Beta;" "Β"]
   ["&Gamma;" "Γ"] ["&Delta;" "Δ"] ["&Epsilon;" "Ε"] ["&Zeta;" "Ζ"] ["&Eta;" "Η"]
   ["&Theta;" "Θ"] ["&Iota;" "Ι"] ["&Kappa;" "Κ"] ["&Lambda;" "Λ"] ["&Mu;" "Μ"]
   ["&Nu;" "Ν"] ["&Xi;" "Ξ"] ["&Omicron;" "Ο"] ["&Pi;" "Π"] ["&Rho;" "Ρ"]
   ["&Sigma;" "Σ"] ["&Tau;" "Τ"] ["&Upsilon;" "Υ"] ["&Phi;" "Φ"] ["&Chi;" "Χ"]
   ["&Psi;" "Ψ"] ["&Omega;" "Ω"] ["&alpha;" "α"] ["&beta;" "β"] ["&gamma;" "γ"]
   ["&delta;" "δ"] ["&epsilon;" "ε"] ["&zeta;" "ζ"] ["&eta;" "η"] ["&theta;" "θ"]
   ["&iota;" "ι"] ["&kappa;" "κ"] ["&lambda;" "λ"] ["&mu;" "μ"] ["&nu;" "ν"]
   ["&xi;" "ξ"] ["&omicron;" "ο"] ["&pi;" "π"] ["&rho;" "ρ"] ["&sigmaf;" "ς"]
   ["&sigma;" "σ"] ["&tau;" "τ"] ["&upsilon;" "υ"] ["&phi;" "φ"] ["&chi;" "χ"]
   ["&psi;" "ψ"] ["&omega;" "ω"] ["&thetasym;" "ϑ"] ["&upsih;" "ϒ"] ["&piv;" "ϖ"]
   ["&bull;" "•"] ["&hellip;" "…"] ["&prime;" "′"] ["&Prime;" "″"] ["&oline;" "‾"]
   ["&frasl;" "⁄"] ["&weierp;" "℘"] ["&image;" "ℑ"] ["&real;" "ℜ"] ["&trade;" "™"]
   ["&alefsym;" "ℵ"] ["&larr;" "←"] ["&uarr;" "↑"] ["&rarr;" "→"] ["&darr;" "↓"]
   ["&harr;" "↔"] ["&crarr;" "↵"] ["&lArr;" "⇐"] ["&uArr;" "⇑"] ["&rArr;" "⇒"]
   ["&dArr;" "⇓"] ["&hArr;" "⇔"] ["&forall;" "∀"] ["&part;" "∂"] ["&exist;" "∃"]
   ["&empty;" "∅"] ["&nabla;" "∇"] ["&isin;" "∈"] ["&notin;" "∉"] ["&ni;" "∋"]
   ["&prod;" "∏"] ["&sum;" "∑"] ["&minus;" "−"] ["&lowast;" "∗"] ["&radic;" "√"]
   ["&prop;" "∝"] ["&infin;" "∞"] ["&ang;" "∠"] ["&and;" "∧"] ["&or;" "∨"]
   ["&cap;" "∩"] ["&cup;" "∪"] ["&int;" "∫"] ["&there4;" "∴"] ["&sim;" "∼"]
   ["&cong;" "≅"] ["&asymp;" "≈"] ["&ne;" "≠"] ["&equiv;" "≡"] ["&le;" "≤"]
   ["&ge;" "≥"] ["&sub;" "⊂"] ["&sup;" "⊃"] ["&nsub;" "⊄"] ["&sube;" "⊆"]
   ["&supe;" "⊇"] ["&oplus;" "⊕"] ["&otimes;" "⊗"] ["&perp;" "⊥"] ["&sdot;" "⋅"]
   ["&lceil;" "⌈"] ["&rceil;" "⌉"] ["&lfloor;" "⌊"] ["&rfloor;" "⌋"] ["&lang;" "〈"]
   ["&rang;" "〉"] ["&loz;" "◊"] ["&spades;" "♠"] ["&clubs;" "♣"]
   ["&hearts;" "♥"] ["&diams;" "♦"] ["&quot;" "\""] ["&OElig;" "Œ"] ["&oelig;" "œ"]
   ["&Scaron;" "Š"] ["&scaron;" "š"] ["&Yuml;" "Ÿ"] ["&circ;" "ˆ"]
   ["&tilde;" "˜"] ["&ndash;" "–"] ["&mdash;" "—"] ["&lsquo;" "‘"] ["&rsquo;" "’"]
   ["&sbquo;" "‚"] ["&ldquo;" "“"] ["&rdquo;" "”"] ["&bdquo;" "„"]
   ["&dagger;" "†"] ["&Dagger;" "‡"] ["&permil;" "‰"] ["&lsaquo;" "‹"] ["&rsaquo;" "›"]
   ["&euro;" "€"]]
  "A list of sequence string pairs, representing an html entity and its decoded
character.")

(defun +web--entities-string (text &optional decode-p)
  "HTML encode/decode TEXT. Based on Xah's replace HTML named entities function
@ http://ergoemacs.org/emacs/elisp_replace_html_entities_command.html"
  (interactive "<!><r>")
  (mapc (lambda (rep)
          (let ((from (elt rep (if decode-p 0 1)))
                (to   (elt rep (if decode-p 1 0)))
                case-fold-search)
            (when (and (not (equal from " "))
                       (string-match-p (regexp-quote from) text))
              (setq text (replace-regexp-in-string (regexp-quote from) to text t t)))))
        +web-entities-list)
  text)

(defun +web--entities-region (beg end &optional decode-p)
  "HTML encode/decode the selected region. Based on Xah's replace HTML named entities
function @ http://ergoemacs.org/emacs/elisp_replace_html_entities_command.html"
  (save-restriction
    (narrow-to-region beg end)
    (mapc (lambda (rep)
            (let ((from (elt rep (if decode-p 0 1)))
                  (to   (elt rep (if decode-p 1 0)))
                  case-fold-search)
              (unless (equal from " ")
                (goto-char (point-min))
                (while (search-forward from nil t)
                  (replace-match to 'FIXEDCASE 'LITERAL)))))
          +web-entities-list)))

;;;###autoload
(defun +web-encode-entities (text)
  "TODO"
  (+web--entities-string text nil))

;;;###autoload
(defun +web-decode-entities (text)
  "TODO"
  (+web--entities-string text t))


;;
;;; Commands

;;;###autoload
(defun +web/encode-entities-region (beg end)
  "Encode HTML entities in region."
  (interactive "r")
  (+web--entities-region beg end))

;;;###autoload
(defun +web/decode-entities-region (beg end)
  "Decode HTML entities in region."
  (interactive "r")
  (+web--entities-region beg end t))

;;;###autoload
(defun +web/indent-or-yas-or-emmet-expand ()
  "Do-what-I-mean on TAB.

Invokes `indent-for-tab-command' if at or before text bol, `yas-expand' if on a
snippet, or `emmet-expand-yas'/`emmet-expand-line', depending on whether
`yas-minor-mode' is enabled or not."
  (interactive)
  (call-interactively
   (cond ((or (<= (current-column) (current-indentation))
              (not (eolp))
              (not (or (memq (char-after) (list ?\n ?\s ?\t))
                       (eobp))))
          #'indent-for-tab-command)
         ((featurep! :editor snippets)
          (require 'yasnippet)
          (if (yas--templates-for-key-at-point)
              #'yas-expand
            #'emmet-expand-yas))
         (#'emmet-expand-line))))

;;;###autoload
(defun +web--go-template-format-buffer ()
  (interactive)
  (web-mode)
  (web-mode-set-engine "go")
  (indent-region (point-min) (point-max))
  (delete-trailing-whitespace (point-min) (point-max)))
