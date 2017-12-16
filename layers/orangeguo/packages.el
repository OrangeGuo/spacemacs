;;; packages.el --- orangeguo layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2017 Sylvain Benner & Contributors
;;
;; Author: orange <orange@orange-X550JX>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;;; Commentary:

;; See the Spacemacs documentation and FAQs for instructions on how to implement
;; a new layer:
;;
;;   SPC h SPC layers RET
;;
;;
;; Briefly, each package to be installed or configured by this layer should be
;; added to `orangeguo-packages'. Then, for each package PACKAGE:
;;
;; - If PACKAGE is not referenced by any other Spacemacs layer, define a
;;   function `orangeguo/init-PACKAGE' to load and initialize the package.


;; - Otherwise, PACKAGE is already referenced by another Spacemacs layer, so
;;   define the functions `orangeguo/pre-init-PACKAGE' and/or
;;   `orangeguo/post-init-PACKAGE' to customize the package as it is loaded.

;;; Code:

(defconst orangeguo-packages
  '(youdao-dictionary
    company
    pyim
;;    company-dict
    lispy)
  

  "The list of Lisp packages required by the orangeguo layer.

Each entry is either:

1. A symbol, which is interpreted as a package to be installed, or

2. A list of the form (PACKAGE KEYS...), where PACKAGE is the
    name of the package to be installed or loaded, and KEYS are
    any number of keyword-value-pairs.

    The following keys are accepted:

    - :excluded (t or nil): Prevent the package from being loaded
      if value is non-nil

    - :location: Specify a custom installation location.
      The following values are legal:

      - The symbol `elpa' (default) means PACKAGE will be
        installed using the Emacs package manager.

      - The symbol `local' directs Spacemacs to load the file at
        `./local/PACKAGE/PACKAGE.el'

      - A list beginning with the symbol `recipe' is a melpa
        recipe.  See: https://github.com/milkypostman/melpa#recipe-format")

;; 初始化 package
;; 可以使用 , d m 快捷键, 然后按下 e 展开宏
(defun orangeguo/init-youdao-dictionary ()
  (use-package youdao-dictionary
    :defer t
    :init
    (spacemacs/set-leader-keys "oy" 'youdao-dictionary-search-at-point+)
    )
  )
;; 定制 company-mode
(defun orangeguo/post-init-company ()
  (setq company-minimum-prefix-length 1)
  )
;; 定制 lispy
(defun orangeguo/init-lispy ())
;; 配置 pyim
(defun orangeguo/init-pyim()
  (use-package pyim
  :ensure nil
  :config
  ;; 激活 basedict 拼音词库
  (use-package pyim-basedict
    :ensure nil
    :config (pyim-basedict-enable))

  (setq default-input-method "pyim")

  ;; 设置 pyim 探针设置，这是 pyim 高级功能设置，可以实现 *无痛* 中英文切换 :-)
  ;; 我自己使用的中英文动态切换规则是：
  ;; 1. 光标只有在注释里面时，才可以输入中文。
  ;; 2. 光标前是汉字字符时，才能输入中文。
  ;; 3. 使用 M-j 快捷键，强制将光标前的拼音字符串转换为中文。
  (setq-default pyim-english-input-switch-functions
                '(pyim-probe-dynamic-english
                  pyim-probe-isearch-mode
                  pyim-probe-program-mode
                  pyim-probe-org-structure-template))

  (setq-default pyim-punctuation-half-width-functions
                '(pyim-probe-punctuation-line-beginning
                  pyim-probe-punctuation-after-punctuation))

  ;; 开启拼音搜索功能
;;  (pyim-isearch-mode nil)

  ;; 使用 pupup-el 来绘制选词框
  (setq pyim-page-tooltip 'popup)

  ;; 选词框显示5个候选词
  (setq pyim-page-length 5)

  ;; 让 Emacs 启动时自动加载 pyim 词库
  (add-hook 'emacs-startup-hook
            #'(lambda () (pyim-restart-1 t)))
  :bind
  (("M-j" . pyim-convert-code-at-point) ;与 pyim-probe-dynamic-english 配合
   ("C-;" . pyim-delete-word-from-personal-buffer)))
  )
;;配置英文单词补全
;;(defun orangeguo/init-company-dict ())
;;; packages.el ends here
;;(require 'company-dict)

;; Where to look for dictionary files. Default is ~/.emacs.d/dict
;;(setq company-dict-dir (concat "~/.spacemacs.d/" "dict/"))

;; Optional: if you want it available everywhere
;;(add-to-list 'company-backends 'company-dict)

;; Optional: evil-mode users may prefer binding this to C-x C-k for vim
;; omni-completion-like dictionary completion
;;(define-key evil-insert-state-map (kbd "C-x C-k") 'company-dict)







