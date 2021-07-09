;;; checkers/spell/autoload/+spell-fu.el -*- lexical-binding: t; -*-
;;;###if (not (featurep! +flyspell))

(defun +spell--correct (replace poss word orig-pt start end)
  (cond ((eq replace 'ignore)
         (goto-char orig-pt)
         nil)
        ((eq replace 'save)
         (goto-char orig-pt)
         (ispell-send-string (concat "*" word "\n"))
         (ispell-send-string "#\n")
         (setq ispell-pdict-modified-p '(t)))
        ((or (eq replace 'buffer) (eq replace 'session))
         (ispell-send-string (concat "@" word "\n"))
         (add-to-list 'ispell-buffer-session-localwords word)
         (or ispell-buffer-local-name ; session localwords might conflict
             (setq ispell-buffer-local-name (buffer-name)))
         (if (null ispell-pdict-modified-p)
             (setq ispell-pdict-modified-p
                   (list ispell-pdict-modified-p)))
         (goto-char orig-pt)
         (if (eq replace 'buffer)
             (ispell-add-per-file-word-list word)))
        (replace
         (let ((new-word (if (atom replace)
                             replace
                           (car replace)))
               (orig-pt (+ (- (length word) (- end start))
                           orig-pt)))
           (unless (equal new-word (car poss))
             (delete-region start end)
             (goto-char start)
             (insert new-word))))
        ((goto-char orig-pt)
         nil)))

(defun +spell-correct-ivy-fn (candidates word)
  (ivy-read (format "Corrections for %S: " word) candidates))

(defun +spell-correct-helm-fn (candidates word)
  (helm :sources (helm-build-sync-source
                  "Ispell"
                  :candidates candidates)
        :prompt (format "Corrections for %S: " word)))

(defun +spell-correct-generic-fn (candidates word)
  (completing-read (format "Corrections for %S: " word) candidates))

;;;###autoload
(defun +spell/correct ()
  "Correct spelling of word at point."
  (interactive)
  ;; spell-fu fails to initialize correctly if it can't find aspell or a similar
  ;; program. We want to signal the error, not tell the user that every word is
  ;; spelled correctly.
  (unless (;; This is what spell-fu uses to check for the aspell executable
           or (and ispell-really-aspell ispell-program-name)
              (executable-find "aspell"))
    (user-error "Aspell is required for spell checking"))

  (ispell-set-spellchecker-params)
  (save-current-buffer
    (ispell-accept-buffer-local-defs))
  (if (not (or (featurep! :completion ivy)
               (featurep! :completion helm)
               (featurep! :completion vertico)))
      (call-interactively #'ispell-word)
    (cl-destructuring-bind (start . end)
        (or (bounds-of-thing-at-point 'word)
            (user-error "No word at point"))
      (let ((word (thing-at-point 'word t))
            (orig-pt (point))
            poss ispell-filter)
        (ispell-send-string "%\n")
        (ispell-send-string (concat "^" word "\n"))
        (while (progn (accept-process-output ispell-process)
                      (not (string= "" (car ispell-filter)))))
        ;; Remove leading empty element
        (setq ispell-filter (cdr ispell-filter))
        ;; ispell process should return something after word is sent. Tag word as
        ;; valid (i.e., skip) otherwise
        (unless ispell-filter
          (setq ispell-filter '(*)))
        (when (consp ispell-filter)
          (setq poss (ispell-parse-output (car ispell-filter))))
        (cond
         ((or (eq poss t) (stringp poss))
          ;; don't correct word
          (message "%s is correct" (funcall ispell-format-word-function word))
          t)
         ((null poss)
          ;; ispell error
          (error "Ispell: error in Ispell process"))
         (t
          ;; The word is incorrect, we have to propose a replacement.
          (setq res (funcall +spell-correct-interface (nth 2 poss) word))
          ;; Some interfaces actually eat 'C-g' so it's impossible to stop rapid
          ;; mode. So when interface returns nil we treat it as a stop.
          (unless res (setq res (cons 'break word)))
          (cond
           ((stringp res)
            (+spell--correct res poss word orig-pt start end))
           ((let ((cmd (car res))
                  (wrd (cdr res)))
              (unless (or (eq cmd 'skip)
                          (eq cmd 'break)
                          (eq cmd 'stop))
                (+spell--correct cmd poss wrd orig-pt start end)
                (unless (string-equal wrd word)
                  (+spell--correct wrd poss word orig-pt start end))))))
          (ispell-pdict-save t)))))))

;;;###autoload (defalias '+spell/add-word #'spell-fu-word-add)
;;;###autoload (defalias '+spell/remove-word #'spell-fu-word-remove)
;;;###autoload (defalias '+spell/next-error #'spell-fu-goto-next-error)
;;;###autoload (defalias '+spell/previous-error #'spell-fu-goto-previous-error)
