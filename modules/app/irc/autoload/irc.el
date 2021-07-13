;;; app/irc/autoload/email.el -*- lexical-binding: t; -*-

(defvar +irc--workspace-name "*IRC*")

(defun +irc-setup-wconf (&optional inhibit-workspace)
  (when (and (featurep! :ui workspaces)
             (not inhibit-workspace))
    (+workspace-switch +irc--workspace-name 'auto-create))
  (let ((buffers (doom-buffers-in-mode 'circe-mode nil t)))
    (if (not (member (window-buffer) buffers))
        (if buffers
            (ignore (switch-to-buffer (car buffers)))
          (require 'circe)
          (delete-other-windows)
          (switch-to-buffer (doom-fallback-buffer))
          t)
      (user-error "IRC buffer is already active and selected"))))

;;;###autoload
(defun =irc (&optional inhibit-workspace)
  "Connect to IRC and auto-connect to all registered networks.

If INHIBIT-WORKSPACE (the universal argument) is non-nil, don't spawn a new
workspace for it."
  (interactive "P")
  (+irc-setup-wconf inhibit-workspace)
  (cond ((doom-buffers-in-mode 'circe-mode (doom-buffer-list) t)
         (message "Circe buffers are already open"))
        (circe-network-options
         (mapc #'circe (mapcar #'car circe-network-options)))
        ((call-interactively #'circe))))

;;;###autoload
(defun +irc/connect (&optional inhibit-workspace)
  "Connect to a specific registered server.

If INHIBIT-WORKSPACE (the universal argument) is non-nil, don't spawn a new
workspace for it."
  (interactive "P")
  (and (+irc-setup-wconf inhibit-workspace)
       (call-interactively #'circe)))

;;;###autoload
(defun +irc/send-message (who what)
  "Send WHO a message containing WHAT."
  (interactive "sWho: \nsWhat: ")
  (circe-command-MSG who what))

;;;###autoload
(defun +irc/quit ()
  "Kill current circe session and workgroup."
  (interactive)
  (unless (y-or-n-p "Really kill IRC session?")
    (user-error "Aborted"))
  (let (circe-channel-killed-confirmation
        circe-server-killed-confirmation)
    (when +irc--defer-timer
      (cancel-timer +irc--defer-timer))
    (disable-circe-notifications)
    (mapc #'kill-buffer (doom-buffers-in-mode 'circe-mode (buffer-list) t))
    (when (featurep! :ui workspaces)
      (when (equal (+workspace-current-name) +irc--workspace-name)
        (+workspace/delete +irc--workspace-name)))))

;;;###autoload
(defun +irc/jump-to-channel (&optional this-server)
  "Jump to an open channel or server buffer. If THIS-SERVER (universal
argument) is non-nil only show channels in current server."
  (interactive "P")
  (call-interactively
   (cond ((featurep! :completion ivy)       #'+irc/ivy-jump-to-channel)
         ((featurep! :completion vertico)   #'+irc/vertico-jump-to-channel)
         ((user-error "No jump-to-channel backend is enabled. Enable vertico or ivy!")))))

;;;###autoload
(defun +irc--circe-all-buffers ()
  (cl-loop with servers = (circe-server-buffers)
           for server in servers
           collect server
           nconc
           (with-current-buffer server
             (cl-loop for buf in (circe-server-chat-buffers)
                      collect buf))))

;;;###autoload
(defun +irc/tracking-next-buffer ()
  "Disables switching to an unread buffer unless in the irc workspace."
  (interactive)
  (when (derived-mode-p 'circe-mode)
    (tracking-next-buffer)))


;;
;;; Hooks/fns

;;;###autoload
(defun +circe-buffer-p (buf)
  "Return non-nil if BUF is a `circe-mode' buffer."
  (with-current-buffer buf
    (derived-mode-p 'circe-mode)))

;;;###autoload
(defun +irc--add-circe-buffer-to-persp-h ()
  (when (and (bound-and-true-p persp-mode)
             (+workspace-exists-p +irc--workspace-name))
    (let ((persp (get-current-persp))
          (buf (current-buffer)))
      ;; Add a new circe buffer to irc workspace when we're in another workspace
      (unless (eq (safe-persp-name persp) +irc--workspace-name)
        ;; Add new circe buffers to the persp containing circe buffers
        (persp-add-buffer buf (persp-get-by-name +irc--workspace-name))
        ;; Remove new buffer from accidental workspace
        (persp-remove-buffer buf persp)))))
