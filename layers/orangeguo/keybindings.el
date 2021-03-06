;; dwin = do what i mean.
(defun occur-dwim ()
  "Call `occur' with a sane default."
  (interactive)
  (push (if (region-active-p)
	          (buffer-substring-no-properties
	           (region-beginning)
	           (region-end))
	        (let ((sym (thing-at-point 'symbol)))
	          (when (stringp sym)
	            (regexp-quote sym))))
	      regexp-history)
  (call-interactively 'occur))
(defun orangeguo/open-file-with-projectile-or-counsel-git ()
  (interactive)
  (if (vcs-project-root)
      (counsel-git)
    (if (projectile-project-p)
	      (projectile-find-file)
      (ido-find-file))))

(define-key evil-visual-state-map (kbd "<f1>") 'orangeguo/evil-quick-replace-allbuffer)
(define-key evil-visual-state-map (kbd "<f2>") 'orangeguo/evil-quick-replace-line)
;; 定义快捷键
(global-set-key (kbd "M-s o") 'occur-dwim)
