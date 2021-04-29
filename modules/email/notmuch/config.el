;;; email/notmuch/config.el -*- lexical-binding: t; -*-

;; FIXME This module is a WIP!

(defvar +notmuch-home-function #'notmuch
  "Function for customizing the landing page for doom-emacs =notmuch.")

(defvar +notmuch-sync-backend 'gmi
  "Which backend to use to synchrone email.
Accepts a symbol or a shell command string.

More specifically, this accepts one of the following symbols (see
`+notmuch-get-sync-command' definition for details):

  `gmi'         Use gmailieer (https://github.com/gauteh/lieer)
  `mbsync'      Use isync (https://isync.sourceforge.io)
  `offlineimap' Use offlineimap (https://www.offlineimap.org)

OR a shell command string such as

  \"path/to/some/shell-script.sh\"
  \"offlineimap && notmuch new && afew -a -t\"
  \"mbsync %s -a && notmuch new && afew -a -t\"")

(defvar +notmuch-mail-folder "~/.mail/account.gmail"
  "Where your email folder is located (for use with gmailieer).")


;;
;;; Packages

(use-package! notmuch
  :defer t
  :init
  (after! org
    (add-to-list 'org-modules 'ol-notmuch))
  :config
  (set-company-backend! 'notmuch-message-mode
    'notmuch-company '(company-ispell company-yasnippet))

  (set-popup-rule! "^\\*notmuch-hello" :side 'left :size 30 :ttl 0)

  (setq notmuch-fcc-dirs nil
        message-kill-buffer-on-exit t
        message-send-mail-function 'message-send-mail-with-sendmail
        send-mail-function 'sendmail-send-it
        ;; sendmail-program "/usr/local/bin/msmtp"
        notmuch-search-result-format
        '(("date" . "%12s ")
          ("count" . "%-7s ")
          ("authors" . "%-30s ")
          ("subject" . "%-72s ")
          ("tags" . "(%s)"))
        notmuch-tag-formats
        '(("unread" (propertize tag 'face 'notmuch-tag-unread)))
        notmuch-saved-searches
        '((:name "inbox"   :query "tag:inbox not tag:trash" :key "i")
          (:name "flagged" :query "tag:flagged"             :key "f")
          (:name "sent"    :query "tag:sent"                :key "s")
          (:name "drafts"  :query "tag:draft"               :key "d"))
        notmuch-archive-tags '("-inbox" "-unread"))
  (setq-default notmuch-search-oldest-first nil)

  ;; only unfold unread messages in thread by default
  (add-hook 'notmuch-show-hook #'+notmuch-show-expand-only-unread-h)

  (add-hook 'doom-real-buffer-functions #'notmuch-interesting-buffer)

  (advice-add #'notmuch-start-notmuch-sentinel :around #'+notmuch-dont-confirm-on-kill-process-a)

  ;; modeline doesn't have much use in these modes
  (add-hook! '(notmuch-show-mode-hook
               notmuch-tree-mode-hook
               notmuch-search-mode-hook)
             #'hide-mode-line-mode)
 
  (map! :localleader
        :map (notmuch-hello-mode-map notmuch-search-mode-map notmuch-tree-mode-map notmuch-show-mode-map)
        :desc "Compose email"   "c" #'+notmuch/compose
        :desc "Sync email"      "u" #'+notmuch/update
        :desc "Quit notmuch"    "q" #'+notmuch/quit
        :map notmuch-search-mode-map
        :desc "Mark as deleted" "d" #'+notmuch/search-delete
        :desc "Mark as spam"    "s" #'+notmuch/search-spam
        :map notmuch-tree-mode-map
        :desc "Mark as deleted" "d" #'+notmuch/tree-delete
        :desc "Mark as spam"    "s" #'+notmuch/tree-spam))


(use-package! org-mime
  :when (featurep! +org)
  :after (org notmuch)
  :config (setq org-mime-library 'mml))


(use-package! counsel-notmuch
  :when (featurep! :completion ivy)
  :commands counsel-notmuch
  :after notmuch)


(use-package! helm-notmuch
  :when (featurep! :completion helm)
  :commands helm-notmuch
  :after notmuch)


(use-package! consult-notmuch
  :when (featurep! :completion selectrum)
  :commands consult-notmuch
  :after notmuch)
