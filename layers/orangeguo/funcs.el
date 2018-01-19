(global-prettify-symbols-mode 1)
(setq-default fill-column 80)
;; ====================================Themes automatically change =====================================
;;timer for automatically changing themes
(setq orangeguo--interval-timer nil)

;;table is used to save (time themes) pair for automatically changing themes
;;time should be a string. themes should be a variant , not symbos.
(setq orangeguo--time-themes-table nil)

(defun orangeguo/config-time-themes-table (tt)
  "Set time . themes table for time-themes-table."
  (setq orangeguo--time-themes-table
      ;; sort firstly, get-themes-according require a sorted table.
      (sort tt (lambda (x y) (< (string-to-number (car x)) (string-to-number (car y)))))
        )
  )

(defun orangeguo/get-themes-according (hour-string)
  "This function return the theme according to hour-string.
Value of hour-string should be between 1 and 24(including)."
  (catch 'break
    (let (
          (now-time (string-to-number hour-string))
          ;; init current-themes to the themes of final item
          (correct-themes (cdr (car (last orangeguo--time-themes-table))))
          (loop-list orangeguo--time-themes-table)
          )

        ;; loop to set correct themes to correct-themes
        (while loop-list
          (let ((v (car loop-list)))
            (let ((v-time (string-to-number (car v))) (v-themes (cdr v)))
              (if (< now-time v-time)
                (throw 'break correct-themes)  ; t
                (setq correct-themes v-themes) ; nil
                )))
          (setq loop-list (cdr loop-list))
        )
        ;; This is returned for value of hour-string is bigger than or equal to car of final item
        (throw 'break correct-themes) ; t
    ))
)

(defun orangeguo/check-time-and-modify-theme ()
  "This function will get the theme of now according to time-table-themes,
then check whether emacs should to modify theme, if so, modify it."
  (let ((new-theme (orangeguo/get-themes-according (format-time-string "%H"))))
    (unless (eq new-theme spacemacs--cur-theme)
      (message "check time to set theme")
      (spacemacs/load-theme new-theme)
    ))
  )

(defun orangeguo/open-themes-auto-change ()
  "Start to automatically change themes."
  (interactive)
  (orangeguo/check-time-and-modify-theme)
  (setq
   orangeguo--interval-timer (run-at-time 5 900 'orangeguo/check-time-and-modify-theme))
  (message "themes auto change open.")
  )

(defun orangeguo/close-themes-auto-change ()
  "Close automatically change themes."
  (interactive)
  (cancel-timer orangeguo--interval-timer)
  (message "themes auto change close.")
  )
;; used by org-clock-sum-today-by-tags
(defun filter-by-tags ()
   (let ((head-tags (org-get-tags-at)))
     (member current-tag head-tags)))

(defun org-clock-sum-today-by-tags (timerange &optional tstart tend noinsert)
  (interactive "P")
  (let* ((timerange-numeric-value (prefix-numeric-value timerange))
         (files (org-add-archive-files (org-agenda-files)))
         (include-tags '("ACADEMIC" "ENGLISH" "SCHOOL"
                         "LEARNING" "OUTPUT" "OTHER"))
         (tags-time-alist (mapcar (lambda (tag) `(,tag . 0)) include-tags))
         (output-string "")
         (tstart (or tstart
                     (and timerange (equal timerange-numeric-value 4) (- (org-time-today) 86400))
                     (and timerange (equal timerange-numeric-value 16) (org-read-date nil nil nil "Start Date/Time:"))
                     (org-time-today)))
         (tend (or tend
                   (and timerange (equal timerange-numeric-value 16) (org-read-date nil nil nil "End Date/Time:"))
                   (+ tstart 86400)))
         h m file item prompt donesomething)
    (while (setq file (pop files))
      (setq org-agenda-buffer (if (file-exists-p file)
                                  (org-get-agenda-file-buffer file)
                                (error "No such file %s" file)))
      (with-current-buffer org-agenda-buffer
        (dolist (current-tag include-tags)
          (org-clock-sum tstart tend 'filter-by-tags)
          (setcdr (assoc current-tag tags-time-alist)
                  (+ org-clock-file-total-minutes (cdr (assoc current-tag tags-time-alist)))))))
    (while (setq item (pop tags-time-alist))
      (unless (equal (cdr item) 0)
        (setq donesomething t)
        (setq h (/ (cdr item) 60)
              m (- (cdr item) (* 60 h)))
        (setq output-string (concat output-string (format "[-%s-] %.2d:%.2d\n" (car item) h m)))))
    (unless donesomething
      (setq output-string (concat output-string "[-Nothing-] Done nothing!!!\n")))
    (unless noinsert
        (insert output-string))
    output-string))
;; replace
(defun orangeguo/evil-quick-replace-allbuffer (beg end)
  (interactive "r")
  (when (evil-visual-state-p)
    (evil-exit-visual-state)
    (let ((selection (regexp-quote (buffer-substring-no-properties beg end))))
      (setq command-string (format "%%s /%s//g" selection))
      (minibuffer-with-setup-hook
          (lambda () (backward-char 2))
        (evil-ex command-string)))))
(defun orangeguo/evil-quick-replace-line (beg end)
  (interactive "r")
  (when (evil-visual-state-p)
    (evil-exit-visual-state)
    (let ((selection (regexp-quote (buffer-substring-no-properties beg end))))
      (setq command-string (format "s /%s//g" selection))
      (minibuffer-with-setup-hook
          (lambda () (backward-char 2))
        (evil-ex command-string)))))
;; auto indent in org-mode
(add-hook 'org-mode-hook (lambda () (org-indent-mode 1)))

;; auto enable lispy-mode 
;; (add-hook 'emacs-lisp-mode-hook (lambda () (lispy-mode 1)))
;; (org-babel-do-load-languages
;;  'org-babel-load-languages '((emacs-lisp . t)))

;;set auto complete for english writing
;; (require 'company)
(add-hook 'after-init-hook 'hybrid-mode)
(add-hook 'after-init-hook 'global-company-mode)
(add-hook 'company-mode-hook (lambda () (setq company-minimum-prefix-length 3)))

;; Don't enable company-mode in below major modes, OPTIONAL
(setq company-global-modes '(not eshell-mode comint-mode erc-mode rcirc-mode))

;; "text-mode" is a major mode for editing files of text in a human language"
;; most major modes for non-programmers inherit from text-mode
(defun text-mode-hook-setup ()
  ;; make `company-backends' local is critcal
  ;; or else, you will have completion in every major mode, that's very annoying!
  (make-local-variable 'company-backends)

  ;; company-ispell is the plugin to complete words
  (add-to-list 'company-backends 'company-ispell)

  ;; OPTIONAL, if `company-ispell-dictionary' is nil, `ispell-complete-word-dict' is used
  ;;  but I prefer hard code the dictionary path. That's more portable.
  (setq company-ispell-dictionary (file-truename "~/.spacemacs.d/dict/english-words.txt")))

(add-hook 'text-mode-hook 'text-mode-hook-setup)

(defun toggle-company-ispell ()
  (interactive)
  (cond
   ((memq 'company-ispell company-backends)
    (setq company-backends (delete 'company-ispell company-backends))
    (message "company-ispell disabled"))
   (t
    (add-to-list 'company-backends 'company-ispell)
    (message "company-ispell enabled!"))))

  (setq tramp-ssh-controlmaster-options
        "-o ControlMaster=auto -o ControlPath='tramp.%%C' -o ControlPersist=no")
  ;; define the refile targets
  (defvar org-agenda-dir "" "gtd org files location")
  (setq-default org-agenda-dir "~/org-notes")
  (setq org-agenda-file-note (expand-file-name "notes.org" org-agenda-dir))
  (setq org-agenda-file-gtd (expand-file-name "gtd.org" org-agenda-dir))
  (setq org-agenda-file-journal (expand-file-name "journal.org" org-agenda-dir))
  (setq org-agenda-file-code-snippet (expand-file-name "snippet.org" org-agenda-dir))
  (setq org-default-notes-file (expand-file-name "gtd.org" org-agenda-dir))
  (setq org-agenda-files (list org-agenda-dir))

  (with-eval-after-load 'org-agenda
    (define-key org-agenda-mode-map (kbd "P") 'org-pomodoro)
    (spacemacs/set-leader-keys-for-major-mode 'org-agenda-mode
      "." 'spacemacs/org-agenda-transient-state/body)
    )
  ;; the %i would copy the selected text into the template
  ;;http://www.howardism.org/Technical/Emacs/journaling-org.html
  ;;add multi-file journal
(setq org-todo-keywords
      (quote ((sequence "TODO(t)" "NEXT(n)" "OFTEN(o)"  "WAIT(w@/!)" "LAST(l)" "|" "CANC(c@/!)"  "DONE(d)"))))

(setq org-todo-keyword-faces
      (quote (("TODO" :foreground "red" :weight bold)
              ("NEXT" :foreground "blue" :weight bold)
              ("DONE" :foreground "forest green" :weight bold)
              ("OFTEN":foreground "yellow" :weight bold)
              ("WAIT" :foreground "orange" :weight bold)
              ("LAST" :foreground "magenta" :weight bold)
              ("CANC" :foreground "gray" :weight bold)
              )))
  (setq org-capture-templates
        '(("t" "Todo" entry (file+headline org-agenda-file-gtd "study")
           "* TODO [#B] %?\n  %i\n"
           :empty-lines 1)
          ("l" "Todo" entry (file+headline org-agenda-file-gtd "life")
           "* TODO [#B] %?\n  %i\n"
           :empty-lines 1)
          ("n" "notes" entry (file+headline org-agenda-file-note "Quick notes")
           "* %?\n  %i\n %U"
           :empty-lines 1)
          ("b" "Blog Ideas" entry (file+headline org-agenda-file-note "Blog Ideas")
           "* TODO [#B] %?\n  %i\n %U"
           :empty-lines 1)
          ("s" "Code Snippet" entry
           (file org-agenda-file-code-snippet)
           "* %?\t%^g\n#+BEGIN_SRC %^{language}\n\n#+END_SRC")
          ("l" "links" entry (file+headline org-agenda-file-note "Quick notes")
           "* TODO [#C] %?\n  %i\n %a \n %U"
           :empty-lines 1)
          ("j" "Journal Entry"
           entry (file+datetree org-agenda-file-journal)
           "* %?"
           :empty-lines 1)))

  ;;An entry without a cookie is treated just like priority ' B '.
  ;;So when create new task, they are default 重要且紧急
  (setq org-agenda-custom-commands
        '(
          ("w" . "task view")
          ("wa" "重要且紧急的任务" tags-todo "+PRIORITY=\"A\"")
          ("wb" "重要且不紧急的任务" tags-todo "-Weekly-Monthly-Daily+PRIORITY=\"B\"")
          ("wc" "不重要且紧急的任务" tags-todo "+PRIORITY=\"C\"")
          ("r" "Weekly Review"
           ((stuck "") ;; review stuck projects as designated by org-stuck-projects
            (tags-todo "life") ;; review all projects (assuming you use todo keywords to designate projects)
            ))))

;; adjust my English and Chinese font for table align
(set-face-attribute
 'default nil
 :font (font-spec :name "-adbe-source code pro-normal-normal-normal-*-*-*-*-*-m-0-iso10646-1"
                  :weight 'normal
                  :slant 'normal
                  :size 18)) 
(dolist (charset '(kana han symbol cjk-misc bopomofo))
  (set-fontset-font
   (frame-parameter nil 'font)
   charset
   (font-spec :name "-zyec-nsimsun-normal-normal-normal-*-*-*-*-*-d-0-iso10646-1"
              :weight 'normal
              :slant 'normal
              :size 16.5)))

