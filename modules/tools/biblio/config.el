;;; tools/biblio/config.el -*- lexical-binding: t; -*-

(use-package! bibtex-completion
  :defer t
  :config
  (setq bibtex-completion-additional-search-fields '(keywords)
        bibtex-completion-pdf-field "file"));; This tell bibtex-completion to look at the File field of the bibtex to figure out which pdf to open


(use-package! ivy-bibtex
  :when (featurep! :completion ivy)
  :defer t
  :config
  (add-to-list 'ivy-re-builders-alist '(ivy-bibtex . ivy--regex-plus)))

;;; Org-Cite configuration

(when (featurep! :lang org)

  ;;; Org-cite processors
  (use-package! oc-basic
    :after oc)

  (use-package! oc-biblatex
    :after oc)

  (use-package! oc-csl
    :after oc
    :init
    ;; optional; add to docs instead?
    (setq org-cite-csl-styles-dir "~/.local/share/csl/styles")
    (setq org-cite-csl-locales-dir "~/.local/share/csl/locales"))

  (use-package! oc-natbib
    :after oc)

  (use-package! bibtex-actions-org-cite
    :when (featurep! :completion vertico)
    :after (org oc bibtex-actions))

  ;;; Org-cite configuration
  (use-package! oc
    :init
    ;; activate processor for fontification, preview, etc
    ;; currently using basic, but would prefer org-cite-csl-activate
    (setq org-cite-activate-processor 'basic)

    (if (featurep :completion vertico)
        (setq org-cite-follow-processor 'bibtex-actions-org-cite
              org-cite-insert-processor 'bibtex-actions-org-cite)
      (setq org-cite-follow-processor 'basic
            org-cite-insert-processor 'basic))

    ;; setup export processor; default csl/citeproc-el, with biblatex for latex
    (setq org-cite-export-processors
          '((latex biblatex nil nil)
            (t csl nil nil)))

    ;; need to set oc to use +biblio-default-bibliography-files
    (setq org-cite-global-bibliography '("~/bib/references.bib"))))
