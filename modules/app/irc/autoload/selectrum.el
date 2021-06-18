;;; app/irc/autoload/selectrum.el -*- lexical-binding: t; -*-
;;;###if (featurep! :completion selectrum)

;;;###autoload
(defun +irc/selectrum-jump-to-channel ()
  "Jump to an open channel or server buffer with selectrum."
  (interactive)
  (require 'consult)
  (consult--multi (list (plist-put (copy-sequence +irc--consult-circe-source)
                                   :hidden nil))
                  :narrow nil
                  :require-match t
                  :prompt "Jump to:"
                  :sort nil))

;;;###autoload
(defvar +irc--consult-circe-source
        `(:name     "circe"
          :hidden   t
          :narrow   ?c
          :category buffer
          :state    ,#'consult--buffer-state
          :items    ,(lambda () (mapcar #'buffer-name (+irc--circe-all-buffers)))))
