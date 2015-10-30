;;
;; ~/.emacs.d/
;;    |- backup
;;    `- site-lisp/
;;

;; Standard package.el + MELPA setup
;; (See also: https://github.com/milkypostman/melpa#usage)
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)

;;set load-path
(setq load-path
      (append (list
               (expand-file-name "~/.emacs.d/site-lisp/")) load-path))

;; Standard Jedi.el setting
(add-hook 'python-mode-hook 'jedi:setup)
(setq jedi:complete-on-dot t)
;; Type:
;;     M-x package-install RET jedi RET
;;     M-x jedi:install-server RET
;; Then open Python file.

;(require 'cython-mode)
;(require 'pypytrace-mode)

;; 一行が 80 字以上になった時には自動改行する
(setq fill-column 10)
(setq-default auto-fill-mode t)

;;font
(add-to-list 'default-frame-alist '(font . "ricty-12"))
(setcdr (assoc 'font default-frame-alist) "ricty-12")
(set-frame-font "ricty-12")

;;high light
(transient-mark-mode 1)

;;show line number
(line-number-mode t)

(setq-default tab-width 2)
(setq tab-width 2)
(setq-default tab-stop-list
              '(0 1 2 3 4 6 8 12 16 20))
(setq-default indent-tabs-mode nil)

;;~file go to backup-dir
(setq backup-dir "~/.emacs.d/backup/")
(setq backup-by-copying t) (fset 'make-backup-file-name
                                 '(lambda (file) (concat (expand-file-name backup-dir)
                                                         (file-name-nondirectory file))))

;; Show tab, zenkaku-space, white spaces at end of line
;; http://www.bookshelf.jp/soft/meadow_26.html#SEC317
(defface my-face-tab '((t (:background "Yellow"))) nil :group 'my-faces)
(defface my-face-zenkaku-spc '((t (:background "LightBlue")))
  nil :group 'my-faces)
(defface my-face-spc-at-eol '((t (:foreground "Red" :underline t)))
  nil :group 'my-faces)
(defvar my-face-tab 'my-face-tab)
(defvar my-face-zenkaku-spc 'my-face-zenkaku-spc)
(defvar my-face-spc-at-eol  'my-face-spc-at-eol)
(defadvice font-lock-mode (before my-font-lock-mode ())
  (font-lock-add-keywords
   major-mode
   '(("\t" 0 my-face-tab append)
     ("　" 0 my-face-zenkaku-spc append)
     ("[ \t]+$" 0 my-face-spc-at-eol append)
     )))
(ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
(ad-activate 'font-lock-mode)

;; settings for text file
(add-hook 'text-mode-hook
          '(lambda ()
             (progn
               (font-lock-mode t)
               (font-lock-fontify-buffer))))
