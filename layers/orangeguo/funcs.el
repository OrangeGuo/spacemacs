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
