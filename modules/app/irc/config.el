;;; app/irc/config.el -*- lexical-binding: t; -*-

(defvar +irc-left-padding 13
  "By how much spaces the left hand side of the line should be padded.
Below a value of 12 this may result in uneven alignment between the various
types of messages.")

(defvar +irc-truncate-nick-char ?…
  "Character to displayed when nick > `+irc-left-padding' in length.")

(defvar +irc-scroll-to-bottom-on-commands
  '(self-insert-command yank hilit-yank)
  "If these commands are called pre prompt the buffer will scroll to `point-max'.")

(defvar +irc-disconnect-hook nil
  "Runs each hook when circe noticies the connection has been disconnected.
Useful for scenarios where an instant reconnect will not be successful.")

(defvar +irc-bot-list '("fsbot" "rudybot")
  "Nicks listed have `circe-fool-face' applied and will not be tracked.")

(defvar +irc-time-stamp-format "%H:%M"
  "The format of time stamps.

See `format-time-string' for a full description of available
formatting directives. ")

(defvar +irc-notifications-watch-strings nil
  "A list of strings which can trigger a notification.  You don't need to put
your nick here.

See `circe-notifications-watch-strings'.")

(defvar +irc-defer-notifications nil
  "How long to defer enabling notifications, in seconds (e.g. 5min = 300).
Useful for ZNC users who want to avoid the deluge of notifications during buffer
playback.")

(defvar +irc--defer-timer nil)

(defsubst +irc--pad (left right)
  (format (format "%%%ds | %%s" +irc-left-padding)
          (concat "*** " left) right))


;;
;; Packages

(use-package! circe
  :commands circe circe-server-buffers
  :config
  (setq circe-default-quit-message nil
        circe-default-part-message nil
        circe-use-cycle-completion t
        circe-reduce-lurker-spam t

        circe-format-say (format "{nick:+%ss} │ {body}" +irc-left-padding)
        circe-format-self-say circe-format-say
        circe-format-action (format "{nick:+%ss} * {body}" +irc-left-padding)
        circe-format-self-action circe-format-action
        circe-format-server-notice
        (let ((left "-Server-")) (concat (make-string (- +irc-left-padding (length left)) ? )
                                         (concat left " _ {body}")))
        circe-format-notice (format "{nick:%ss} _ {body}" +irc-left-padding)
        circe-format-server-topic
        (+irc--pad "Topic" "{userhost}: {topic-diff}")
        circe-format-server-join-in-channel
        (+irc--pad "Join" "{nick} ({userinfo}) joined {channel}")
        circe-format-server-join
        (+irc--pad "Join" "{nick} ({userinfo})")
        circe-format-server-part
        (+irc--pad "Part" "{nick} ({userhost}) left {channel}: {reason}")
        circe-format-server-quit
        (+irc--pad "Quit" "{nick} ({userhost}) left IRC: {reason}]")
        circe-format-server-quit-channel
        (+irc--pad "Quit" "{nick} ({userhost}) left {channel}: {reason}]")
        circe-format-server-rejoin
        (+irc--pad "Re-join" "{nick} ({userhost}), left {departuredelta} ago")
        circe-format-server-netmerge
        (+irc--pad "Netmerge" "{split}, split {ago} ago (Use /WL to see who's still missing)")
        circe-format-server-nick-change
        (+irc--pad "Nick" "{old-nick} ({userhost}) is now known as {new-nick}")
        circe-format-server-nick-change-self
        (+irc--pad "Nick" "You are now known as {new-nick} ({old-nick})")
        circe-format-server-nick-change-self
        (+irc--pad "Nick" "{old-nick} ({userhost}) is now known as {new-nick}")
        circe-format-server-mode-change
        (+irc--pad "Mode" "{change} on {target} by {setter} ({userhost})")
        circe-format-server-lurker-activity
        (+irc--pad "Lurk" "{nick} joined {joindelta} ago"))

  (add-hook 'doom-real-buffer-functions #'+circe-buffer-p)
  (add-hook 'circe-channel-mode-hook #'turn-on-visual-line-mode)
  (add-hook 'circe-mode-hook #'+irc--add-circe-buffer-to-persp-h)
  (add-hook 'circe-mode-hook #'turn-off-smartparens-mode)

  ;; HACK Fix #1862: circe hangs on TLS connections when using OpenSSL versions
  ;;      > 1.1.0, where tls.el does not correctly determine the end of the info
  ;;      block. This fixes proposed in jorgenschaefer/circe#340
  (setq-hook! 'circe-mode-hook
    tls-end-of-info
    (concat "\\("
            ;; `openssl s_client' regexp. See ssl/ssl_txt.c lines 219-220.
            ;; According to apps/s_client.c line 1515 `---' is always the last
            ;; line that is printed by s_client before the real data.
            "^    Verify return code: .+\n\\(\\|^    Extended master secret: .+\n\\)\\(\\|^    Max Early Data: .+\n\\)---\n\\|"
            ;; `gnutls' regexp. See src/cli.c lines 721-.
            "^- Simple Client Mode:\n"
            "\\(\n\\|"                           ; ignore blank lines
            ;; According to GnuTLS v2.1.5 src/cli.c lines 640-650 and 705-715 in
            ;; `main' the handshake will start after this message. If the
            ;; handshake fails, the programs will abort.
            "^\\*\\*\\* Starting TLS handshake\n\\)*"
            "\\)"))

  (defadvice! +irc--circe-run-disconnect-hook-a (&rest _)
    "Runs `+irc-disconnect-hook' after circe disconnects."
    :after #'circe--irc-conn-disconnected
    (run-hooks '+irc-disconnect-hook))

  (add-hook! 'lui-pre-output-hook
    (defun +irc-circe-truncate-nicks-h ()
      "Truncate long nicknames in chat output non-destructively."
      (when-let (beg (text-property-any (point-min) (point-max) 'lui-format-argument 'nick))
        (goto-char beg)
        (let ((end (next-single-property-change beg 'lui-format-argument))
              (nick (plist-get (plist-get (text-properties-at beg) 'lui-keywords)
                               :nick)))
          (when (> (length nick) +irc-left-padding)
            (compose-region (+ beg +irc-left-padding -1) end
                            +irc-truncate-nick-char))))))

  (add-hook! 'circe-message-option-functions
    (defun +irc-circe-message-option-bot-h (nick &rest ignored)
      "Fontify known bots and mark them to not be tracked."
      (when (member nick +irc-bot-list)
        '((text-properties . (face circe-fool-face lui-do-not-track t))))))

  ;; Let `+irc/quit' and `circe' handle buffer cleanup
  (define-key circe-mode-map [remap kill-buffer] #'bury-buffer)
  ;; Fail gracefully if not in a circe buffer
  (global-set-key [remap tracking-next-buffer] #'+irc/tracking-next-buffer)

  (after! marginalia
    (when (featurep! :completion selectrum)
      (add-to-list 'marginalia-command-categories '(+irc/selectrum-jump-to-channel . buffer))))

  (map! :localleader
        (:map circe-mode-map
          "a" #'tracking-next-buffer
          "j" #'circe-command-JOIN
          "m" #'+irc/send-message
          "p" #'circe-command-PART
          "Q" #'+irc/quit
          "R" #'circe-reconnect
          "c" #'+irc/jump-to-channel)
        (:map circe-channel-mode-map
         "n" #'circe-command-NAMES)))


(use-package! circe-color-nicks
  :hook (circe-channel-mode . enable-circe-color-nicks)
  :config
  (setq circe-color-nicks-min-constrast-ratio 4.5
        circe-color-nicks-everywhere t))


(use-package! circe-new-day-notifier
  :after circe
  :config
  (enable-circe-new-day-notifier)
  (setq circe-new-day-notifier-format-message
        (+irc--pad "Day" "Date changed [{day}]")))


(use-package! circe-notifications
  :commands enable-circe-notifications
  :init
  (add-hook! 'circe-server-connected-hook
    (defun +irc-init-circe-notifications-h ()
      (if (numberp +irc-defer-notifications)
          (setq +irc--defer-timer
                (run-at-time +irc-defer-notifications nil
                             #'enable-circe-notifications))
        (enable-circe-notifications))))
  :config
  (setq circe-notifications-watch-strings +irc-notifications-watch-strings
        circe-notifications-emacs-focused nil
        circe-notifications-alert-style
        (cond (IS-MAC 'osx-notifier)
              (IS-LINUX 'libnotify)
              (circe-notifications-alert-style))))


(use-package! lui
  :commands lui-mode
  :config
  (define-key lui-mode-map "\C-u" #'lui-kill-to-beginning-of-line)
  (setq lui-fill-type nil)

  (when (featurep! :checkers spell)
    (setq lui-flyspell-p t))

  (after! evil
    (defun +irc-evil-insert-h ()
      "Ensure entering insert mode will put us at the prompt, unless editing
after prompt marker."
      (when (> (marker-position lui-input-marker) (point))
        (goto-char (point-max))))

    (add-hook! 'lui-mode-hook
      (add-hook 'evil-insert-state-entry-hook #'+irc-evil-insert-h
                nil 'local))

    (mapc (lambda (cmd) (push cmd +irc-scroll-to-bottom-on-commands))
          '(evil-paste-after evil-paste-before evil-open-above evil-open-below)))


  (defun +irc-preinput-scroll-to-bottom-h ()
    "Go to the end of the buffer in all windows showing it.
Courtesy of esh-mode.el"
    (when (memq this-command +irc-scroll-to-bottom-on-commands)
      (let* ((selected (selected-window))
             (current (current-buffer)))
        (when (> (marker-position lui-input-marker) (point))
          (walk-windows
           (function
            (lambda (window)
              (when (eq (window-buffer window) current)
                (select-window window)
                (goto-char (point-max))
                (select-window selected))))
           nil t)))))

  (add-hook! 'lui-mode-hook
    (add-hook 'pre-command-hook #'+irc-preinput-scroll-to-bottom-h nil t))

  ;; enable a horizontal line marking the last read message
  (add-hook 'lui-mode-hook #'enable-lui-track-bar)

  (add-hook! 'lui-mode-hook
    (defun +irc-init-lui-margins-h ()
      (setq lui-time-stamp-position 'right-margin
            lui-time-stamp-format +irc-time-stamp-format
            right-margin-width (length (format-time-string lui-time-stamp-format))))
    (defun +irc-init-lui-wrapping-a ()
      (setq fringes-outside-margins t
            word-wrap t
            wrap-prefix (make-string (+ +irc-left-padding 3) ? )))))


(use-package! lui-logging
  :after lui
  :config (enable-lui-logging))


(use-package! lui-autopaste
  :hook (circe-channel-mode . enable-lui-autopaste))
