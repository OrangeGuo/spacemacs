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
