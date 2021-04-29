;;; editor/evil/+commands.el -*- lexical-binding: t; -*-

;;
;;; Custom commands
;; Editing
(evil-ex-define-cmd "@"            #'+evil:macro-on-all-lines)   ; TODO Test me
(evil-ex-define-cmd "R[ead]"       #'+evil:read)
(evil-ex-define-cmd "al[ign]"      #'+evil:align)
(evil-ex-define-cmd "ral[ign]"     #'+evil:align-right)
(evil-ex-define-cmd "enhtml"       #'+web:encode-html-entities)
(evil-ex-define-cmd "dehtml"       #'+web:decode-html-entities)
(evil-ex-define-cmd "mc"           #'+multiple-cursors:evil-mc)
(evil-ex-define-cmd "iedit"        #'evil-multiedit-ex-match)
(evil-ex-define-cmd "na[rrow]"     #'+evil:narrow-buffer)
(evil-ex-define-cmd "retab"        #'+evil:retab)
(evil-ex-define-cmd "rev[erse]"    #'+evil:reverse-lines)
(evil-ex-define-cmd "l[ine]diff"   #'evil-quick-diff)

;;; External resources
;; TODO (evil-ex-define-cmd "db"          #'doom:db)
;; TODO (evil-ex-define-cmd "dbu[se]"     #'doom:db-select)
;; TODO (evil-ex-define-cmd "go[ogle]"    #'doom:google-search)
(evil-ex-define-cmd "lo[okup]"    #'+lookup:online)
(evil-ex-define-cmd "dash"        #'+lookup:dash)
(evil-ex-define-cmd "http"        #'httpd-start)            ; start http server
(evil-ex-define-cmd "repl"        #'+eval:repl)             ; invoke or send to repl
(evil-ex-define-cmd "h[elp]"      #'+evil:help)

;; TODO (evil-ex-define-cmd "rx"          'doom:regex)             ; open re-builder
(evil-ex-define-cmd "sh[ell]"     #'+eshell:run)
(evil-ex-define-cmd "pad"         #'+evil:open-scratch-buffer)

;;; GIT
(evil-ex-define-cmd "gist"        #'+gist:send)  ; send current buffer/region to gist
(evil-ex-define-cmd "gistl"       #'+gist:list)  ; list gists by user
(evil-ex-define-cmd "gbrowse"     #'+vc/browse-at-remote-file-or-region) ; show file/region in github/gitlab
(evil-ex-define-cmd "gissues"     #'forge-browse-issues)  ; show github issues
(evil-ex-define-cmd "git"         #'magit-status)         ; open magit status window
(evil-ex-define-cmd "gstage"      #'magit-stage)
(evil-ex-define-cmd "gunstage"    #'magit-unstage)
(evil-ex-define-cmd "gblame"      #'magit-blame)
(evil-ex-define-cmd "grevert"     #'git-gutter:revert-hunk)

;;; Dealing with buffers
(evil-ex-define-cmd "k[ill]"      #'doom/kill-current-buffer)
(evil-ex-define-cmd "k[ill]all"   #'+evil:kill-all-buffers)
(evil-ex-define-cmd "k[ill]m"     #'+evil:kill-matching-buffers)
(evil-ex-define-cmd "k[ill]o"     #'doom/kill-other-buffers)
(evil-ex-define-cmd "k[ill]b"     #'doom/kill-buried-buffers)
(evil-ex-define-cmd "l[ast]"      #'+popup/restore)
(evil-ex-define-cmd "messages"    #'view-echo-area-messages)
(evil-ex-define-cmd "pop[up]"     #'+popup/buffer)

;;; Project navigation
(evil-ex-define-cmd "a"           #'projectile-find-other-file)
(evil-ex-define-cmd "cd"          #'+evil:cd)
(evil-ex-define-cmd "pwd"         #'+evil:pwd)

(evil-define-command +evil:swiper (&optional search)
  "Invoke `swiper' with SEARCH, otherwise with the symbol at point."
  (interactive "<a>")
  (swiper-isearch search))
(evil-ex-define-cmd "sw[iper]" #'+evil:swiper)

(cond ((featurep! :completion ivy)
       (evil-ex-define-cmd "pg[rep]"   #'+ivy:project-search)
       (evil-ex-define-cmd "pg[grep]d" #'+ivy:project-search-from-cwd))

      ((featurep! :completion helm)
       (evil-ex-define-cmd "pg[rep]"   #'+helm:project-search)
       (evil-ex-define-cmd "pg[grep]d" #'+helm:project-search-from-cwd))
      ((featurep! :completion selectrum)
       (evil-ex-define-cmd "pg[rep]"   #'+selectrum:project-search)
       (evil-ex-define-cmd "pg[grep]d" #'+selectrum:project-search-from-cwd)))

;;; Project tools
(evil-ex-define-cmd "com[pile]"   #'+evil:compile)
(evil-ex-define-cmd "make"        #'+evil:make)
(evil-ex-define-cmd "mk"          #'+evil:make) ; convenience alias
(evil-ex-define-cmd "debug"       #'+debugger/start)
(evil-ex-define-cmd "er[rors]"    #'flycheck-list-errors)

;;; File operations
(evil-ex-define-cmd "cp"          #'+evil:copy-this-file)
(evil-ex-define-cmd "mv"          #'+evil:move-this-file)
(evil-ex-define-cmd "rm"          #'+evil:delete-this-file)

;;; Sessions/tabs
(evil-ex-define-cmd "sclear"      #'+workspace/kill-session)
(evil-ex-define-cmd "sl[oad]"     #'doom/quickload-session)
(evil-ex-define-cmd "ss[ave]"     #'doom/quicksave-session)
(evil-ex-define-cmd "tabc[lose]"  #'+workspace:delete)
(evil-ex-define-cmd "tabclear"    #'doom/kill-all-buffers)
(evil-ex-define-cmd "tabl[ast]"   #'+workspace/switch-to-last)
(evil-ex-define-cmd "tabload"     #'+workspace:load)
(evil-ex-define-cmd "tabn[ew]"    #'+workspace:new)
(evil-ex-define-cmd "tabnext"     #'+workspace:switch-next)
(evil-ex-define-cmd "tabprev"     #'+workspace:switch-previous)
(evil-ex-define-cmd "tabr[ename]" #'+workspace:rename)
(evil-ex-define-cmd "tabs"        #'+workspace/display)
(evil-ex-define-cmd "tabsave"     #'+workspace:save)

;;; Org-mode
(evil-ex-define-cmd "cap[ture]"   #'org-capture)

;;; ibuffer
(when (featurep! :emacs ibuffer)
  (evil-ex-define-cmd "buffers" #'ibuffer))
