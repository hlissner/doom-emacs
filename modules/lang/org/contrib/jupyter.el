;;; lang/org/contrib/jupyter.el -*- lexical-binding: t; -*-
;;;###if (featurep! +jupyter)

(use-package! ob-jupyter
  :defer t
  :init
  (after! ob-async
    (pushnew! ob-async-no-async-languages-alist
              "jupyter-python"
              "jupyter-julia"
              "jupyter-R"))

  (after! org-src
    (dolist (lang '(python julia R))
      (cl-pushnew (cons (format "jupyter-%s" lang) lang)
                  org-src-lang-modes :key #'car)))

  (add-hook! '+org-babel-load-functions
    (defun +org-babel-load-jupyter-h (lang)
      (when (string-prefix-p "jupyter-" (symbol-name lang))
        (require 'jupyter)
        (let* ((lang-name (symbol-name lang))
               (lang-tail (string-remove-prefix "jupyter-" lang-name)))
          (and (not (assoc lang-tail org-src-lang-modes))
               (require (intern (format "ob-%s" lang-tail))
                        nil t)
               (add-to-list 'org-src-lang-modes (cons lang-name (intern lang-tail)))))
        (with-demoted-errors "Jupyter: %s"
          (require lang nil t)
          (require 'ob-jupyter nil t)))))
  :config
  (defadvice! +org--ob-jupyter-initiate-session-a (&rest _)
    :after #'org-babel-jupyter-initiate-session
    (unless (bound-and-true-p jupyter-org-interaction-mode)
      (jupyter-org-interaction-mode)))

  ;; Remove text/html since it's not human readable
  (delq! :text/html jupyter-org-mime-types)

  (require 'tramp)

  (when (featurep! :completion company +childframe)
    (after! company-box
      (push #'+org--company-box-icons-jupyter-fn company-box-icons-functions))))
