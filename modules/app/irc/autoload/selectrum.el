;;; app/irc/autoload/selectrum.el -*- lexical-binding: t; -*-
;;;###if (featurep! :completion selectrum)

;;;###autoload
(defun +irc/selectrum-jump-to-channel (&optional this-server)
  "Jump to an open channel or server buffer with selectrum. If THIS-SERVER (universal
argument) is non-nil only show channels in current server."
  (interactive "P")
  (if (not (circe-server-buffers))
      (message "No circe buffers available")
    (when (and this-server (not circe-server-buffer))
      (setq this-server nil))
    (when-let
        ((buffer (completing-read
                  (format "Jump to%s: " (if this-server (format " (%s)" (buffer-name circe-server-buffer)) ""))
                  (cl-loop with servers = (if this-server (list circe-server-buffer) (circe-server-buffers))
                           with current-buffer = (current-buffer)
                           for server in servers
                           collect (buffer-name server)
                           nconc
                           (with-current-buffer server
                             (cl-loop for buf in (circe-server-chat-buffers)
                                      unless (eq buf current-buffer)
                                      collect (buffer-name buf)))))))
      (switch-to-buffer buffer))))
