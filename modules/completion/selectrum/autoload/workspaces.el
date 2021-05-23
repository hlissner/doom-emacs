;;; completion/selectrum/autoload/workspaces.el -*- lexical-binding: t; -*-
;;;###if (featurep! :ui workspaces)

;;;###autoload
(defun +selectrum--workspace-nth-source (n)
  "Generate a consult buffer source for buffers in the NTH workspace"
  (cond ((numberp n)
         `(:name     ,(nth n (+workspace-list-names))
           :hidden   ,(not (string= (+workspace-current-name) (nth n (+workspace-list-names))))
           :narrow   ,(string-to-char (number-to-string (1+ n)))
           :category buffer
           :state    ,#'consult--buffer-state
           :items    ,(lambda () (mapcar #'buffer-name (+workspace-buffer-list (nth n (+workspace-list)))))))
        ((eq n 'final)
         `(:name     ,(car (last (+workspace-list-names)))
           :hidden   t
           :narrow   ?0
           :category buffer
           :state    ,#'consult--buffer-state
           :items    ,(lambda () (mapcar #'buffer-name (+workspace-buffer-list (car (last (+workspace-list))))))))
         (t
          (user-error "invalid workspace source %s" n))))

;;;###autoload
(defun +selectrum--workspace-generate-sources ()
  "Generate list of consult buffer sources for all workspaces"
        (mapcar #'+selectrum--workspace-nth-source '(0 1 2 3 4 5 6 7 8 final)))

(autoload 'consult--multi "consult")
;;;###autoload
(defun +selectrum/switch-workspace-buffer ()
  "Switch to another buffer in the same workspace.

Use consult narrowing with another workspace number to open a buffer from that workspace
 BUG but it opens it in the current workspace (ivy also does this, but who cares)"
  (interactive)
  (when-let (buffer (consult--multi (+selectrum--workspace-generate-sources)
                                    :require-match
                                    (confirm-nonexistent-file-or-buffer)
                                    :prompt (format "Switch to buffer (%s): "
                                                    (+workspace-current-name)
                                    :history 'consult--buffer-history
                                    :sort nil)))
    ;; When the buffer does not belong to a source,
    ;; create a new buffer with the name.
    (unless (cdr buffer)
      (funcall consult--buffer-display (car buffer)))))
