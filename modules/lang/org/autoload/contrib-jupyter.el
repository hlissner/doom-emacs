;;; lang/org/autoload/contrib-jupyter.el -*- lexical-binding: t; -*-
;;;###if (featurep! +jupyter)

(defvar +org--company-box-jupyter-icons
  '(("class"     . Class)
    ("function"  . Function)
    ("instance"  . Variable)
    ("keyword"   . Keyword)
    ("module"    . Module)
    ("statement" . Variable)
    ("param"     . Property)
    ("path"      . File)))


;;;###autoload
(defun +org--company-box-icons-jupyter-fn (candidate)
  (when-let (((eq major-mode 'org-mode))
             (info (org-babel-get-src-block-info t))
             ((string-equal (car info) "jupyter-python"))
             (type (string-trim (get-text-property 0 'annot candidate))))
    (alist-get type +org--company-box-jupyter-icons nil nil
               #'string-equal)))
