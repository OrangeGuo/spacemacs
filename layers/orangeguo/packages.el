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
    company)

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
;;; packages.el ends here





