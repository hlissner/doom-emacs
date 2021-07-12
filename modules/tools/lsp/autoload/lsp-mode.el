;;; tools/lsp/autoload/lsp-mode.el -*- lexical-binding: t; -*-
;;;###if (not (featurep! +eglot))

;;;###autodef
(defun set-lsp-priority! (client priority)
  "Change the PRIORITY of lsp CLIENT."
  (require 'lsp-mode)
  (if-let (client (gethash client lsp-clients))
      (setf (lsp--client-priority client)
            priority)
    (error "No LSP client named %S" client)))

;;;###autoload
(defun +lsp/uninstall-server (dir)
  "Delete a LSP server from `lsp-server-install-dir'."
  (interactive
   (list (read-directory-name "Uninstall LSP server: " lsp-server-install-dir nil t)))
  (unless (file-directory-p dir)
    (user-error "Couldn't find %S directory" dir))
  (delete-directory dir 'recursive)
  (message "Uninstalled %S" (file-name-nondirectory dir)))

;;;###autoload
(defun +lsp/switch-client (client)
  "Switch to another LSP server."
  (interactive
   (progn
     (require 'lsp-mode)
     (list (completing-read
            "Select server: "
            (or (mapcar #'lsp--client-server-id (lsp--filter-clients (-andfn #'lsp--matching-clients?
                                                                             #'lsp--server-binary-present?)))
                (user-error "No available LSP clients for %S" major-mode))))))
  (require 'lsp-mode)
  (let* ((client (if (symbolp client) client (intern client)))
         (match (car (lsp--filter-clients (lambda (c) (eq (lsp--client-server-id c) client)))))
         (workspaces (lsp-workspaces)))
    (unless match
      (user-error "Couldn't find an LSP client named %S" client))
    (let ((old-priority (lsp--client-priority match)))
      (setf (lsp--client-priority match) 9999)
      (unwind-protect
          (if workspaces
              (lsp-workspace-restart
               (if (cdr workspaces)
                   (lsp--completing-read "Select server: "
                                         workspaces
                                         'lsp--workspace-print
                                         nil t)
                 (car workspaces)))
            (lsp-mode +1))
       (add-transient-hook! 'lsp-after-initialize-hook
          (setf (lsp--client-priority match) old-priority))))))

;;;###autoload
(defun +lsp-lookup-definition-handler ()
  "Find definition of the symbol at point using LSP."
  (interactive)
  (when-let (loc (lsp-request "textDocument/definition"
                              (lsp--text-document-position-params)))
    (lsp-show-xrefs (lsp--locations-to-xref-items loc) nil nil)
    'deferred))

;;;###autoload
(defun +lsp-lookup-references-handler (&optional include-declaration)
  "Find project-wide references of the symbol at point using LSP."
  (interactive "P")
  (when-let
      (loc (lsp-request "textDocument/references"
                        (append (lsp--text-document-position-params)
                                (list
                                 :context `(:includeDeclaration
                                            ,(lsp-json-bool include-declaration))))))
    (lsp-show-xrefs (lsp--locations-to-xref-items loc) nil t)
    'deferred))
