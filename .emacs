(setq inferior-lisp-program "clisp")

;;
;; ~/.emacs.d/
;;    |- backup
;;    `- site-lisp/
;;        |- auto-complete.el
;;        |- auto-complete.elc
;;        |- espresso.el
;;        |- espresso.elc
;;        |- js2.el
;;        |- js2.elc ;Compiled file from js2.el "M-x byte-compile-file RET ~/.emacs.d/site-lisp/js2.el"
;;        |- yasnippet/
;;        |   |- dropdown-list.el
;;        |   |- dropdown-list.elc
;;        |   |- snippets/
;;        |   |   `- text-mode
;;        |   |       |- */
;;        |   |       `- js2-mode/ //add directory
;;        |   |- yasnippet.el
;;        |   `- yasnippet.elc
;;        |- yasnippet-bundle.el
;;        `- yasnippet-bundle.elc
;;

;;set load-path
(setq load-path
      (append (list
               (expand-file-name "~/.emacs.d/site-lisp/")) load-path))

(require 'pypytrace-mode)

;;auto-complete
;;http://cx4a.org/software/auto-complete/
(require 'auto-complete)
(global-auto-complete-mode t)

;; 一行が 80 字以上になった時には自動改行する
(setq fill-column 10)
(setq-default auto-fill-mode t)

;;js2-mode
;;http://code.google.com/p/js2-mode/
;;; js2-modeをロードする
(autoload 'js2-mode "js2" nil t)
;;; 拡張子.jsのファイルにjs2-modeを適用する
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

;; js2-mode
;;http://code.google.com/p/js2-mode/
;;; js2-modeでのインデントを設定する
(add-hook 'js2-mode-hook '(lambda ()
                            (setq js2-basic-offset 2)
                            (setq tab-width 2)
                            ) t)

;;espresso
;;http://mihai.bazon.net/projects/editing-javascript-with-emacs-js2-mode/
;;http://download-mirror.savannah.gnu.org/releases/espresso/espresso.el
(autoload 'espresso-mode "espresso")
;(add-to-list 'auto-mode-alist '("\\.js$" . espresso-mode))
;(add-to-list 'auto-mode-alist '("\\.json$" . espresso-mode))

;;espresso
;;http://mihai.bazon.net/projects/editing-javascript-with-emacs-js2-mode/
(defun my-js2-indent-function ()
  (interactive)
  (save-restriction
    (widen)
    (let* ((inhibit-point-motion-hooks t)
           (parse-status (save-excursion (syntax-ppss (point-at-bol))))
           (offset (- (current-column) (current-indentation)))
           (indentation (espresso--proper-indentation parse-status))
           node)

      (save-excursion
        ;; I like to indent case and labels to half of the tab width
        (back-to-indentation)
        (if (looking-at "case\\s-")
            (setq indentation (+ indentation (/ espresso-indent-level 2))))

        ;; consecutive declarations in a var statement are nice if
        ;; properly aligned, i.e:
        ;;
        ;; var foo = "bar",
        ;;     bar = "foo";
        (setq node (js2-node-at-point))
        (when (and node
                   (= js2-NAME (js2-node-type node))
                   (= js2-VAR (js2-node-type (js2-node-parent node))))
          (setq indentation (+ 2 indentation))))

      (indent-line-to indentation)
      (when (> offset 0) (forward-char offset)))))

;;espresso
;;http://mihai.bazon.net/projects/editing-javascript-with-emacs-js2-mode/
(defun my-indent-sexp ()
  (interactive)
  (save-restriction
    (save-excursion
      (widen)
      (let* ((inhibit-point-motion-hooks t)
             (parse-status (syntax-ppss (point)))
             (beg (nth 1 parse-status))
             (end-marker (make-marker))
             (end (progn (goto-char beg) (forward-list) (point)))
             (ovl (make-overlay beg end)))
        (set-marker end-marker end)
        (overlay-put ovl 'face 'highlight)
        (goto-char beg)
        (while (< (point) (marker-position end-marker))
          ;; don't reindent blank lines so we don't set the "buffer
          ;; modified" property for nothing
          (beginning-of-line)
          (unless (looking-at "\\s-*$")
            (indent-according-to-mode))
          (forward-line))
        (run-with-timer 0.5 nil '(lambda(ovl)
                                   (delete-overlay ovl)) ovl)))))

;;espresso
;;http://mihai.bazon.net/projects/editing-javascript-with-emacs-js2-mode/
(defun my-js2-mode-hook ()
  (require 'espresso)
  (setq espresso-indent-level 2
        indent-tabs-mode nil)
  (c-toggle-auto-state 0)
  (c-toggle-hungry-state 1)
  (set (make-local-variable 'indent-line-function) 'my-js2-indent-function)
  (define-key js2-mode-map [(meta control |)] 'cperl-lineup)
  (define-key js2-mode-map [(meta control \;)]
    '(lambda()
       (interactive)
       (insert "/* -----[ ")
       (save-excursion
         (insert " ]----- */"))
       ))
  (define-key js2-mode-map [(return)] 'newline-and-indent)
  (define-key js2-mode-map [(backspace)] 'c-electric-backspace)
  (define-key js2-mode-map [(control d)] 'c-electric-delete-forward)
  (define-key js2-mode-map [(control meta q)] 'my-indent-sexp)
  (if (featurep 'js2-highlight-vars)
    (js2-highlight-vars-mode))
  (message "My JS2 hook"))

(add-hook 'js2-mode-hook 'my-js2-mode-hook)

;;yasnippet-bundle
;;http://code.google.com/p/yasnippet/
(require 'yasnippet-bundle)

;;yasnippet
;;http://code.google.com/p/yasnippet/
(require 'yasnippet)
(yas/initialize)
(yas/load-directory "~/.emacs.d/site-lisp/yasnippet/snippets")

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
(file-name-nondirectory file)) ))

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
