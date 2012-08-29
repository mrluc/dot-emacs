(require 'package)
(add-to-list 
 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/") t)
(package-initialize)

;; Check if system is Darwin/Mac OS X
(defun is-mac () (interactive) "Are we on Darwin?" (string-equal system-type "darwin"))

(defun set-exec-path-from-shell-PATH ()
  "Set up Emacs' `exec-path' and PATH environment variable to match that used by the user's shell."
  (interactive)
  (let ((path-from-shell (string-rtrim (shell-command-to-string "$SHELL --login -i -c 'echo $PATH'"))))
    (setenv "PATH" path-from-shell)
    (setq exec-path (split-string path-from-shell path-separator))))

(when (and (is-mac) window-system)
  (set-exec-path-from-shell-PATH))

;;;; VISUAL APPEARANCE
;;   TODO the backgrounds are 256-color CONSOLE specific
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

(set 'tab-width 2)
(setq-default truncate-lines t)
(set-face-foreground 'highlight nil) ;; always, this
(set-face-underline 'highlight nil)  ;; always, this

(load-theme 'wombat)
(set-face-background 'highlight "gray13") ;; 256-color
(set-face-background 'default (if (is-mac) "gray10" "gray8"))    ;; wombat
(set-default-font "Liberation Mono 9")    
(set-face-attribute 'default nil :height (if (is-mac) 100 85)) ;; 1/10th of a pt apiece


;;; WINDOW MANAGEMENT and NAV
;;;
(dolist (key '("\C-z"))
  (global-unset-key key)) ;;; bad emacs!
(defun global-set-keys (alist) nil
  (mapcar (lambda (a) nil
            (setcar a (read-kbd-macro (car a)))
            (apply 'global-set-key a)) alist)) 
(global-set-keys
 '(( "M-s M-<left>  " shrink-window-horizontally) ; resize pane
   ( "M-s M-<right> " enlarge-window-horizontally)
   ( "M-s M-<down>  " shrink-window)
   ( "M-s M-<up>    " enlarge-window)
   ( "<f11>         " (if (is-mac) ns-toggle-fullscreen toggle-fullscreen))
   ( "C-c C-<left>  " windmove-left)        ; jump cursor from pane to pane
   ( "C-c C-<right> " windmove-right)       ;  in a natural fashion
   ( "C-c C-<up>    " windmove-up)
   ( "C-c C-<down>  " windmove-down)))

(defun toggle-fullscreen (&optional f)
      (interactive)
      (let ((current-value (frame-parameter nil 'fullscreen)))
           (set-frame-parameter nil 'fullscreen
                                (if (equal 'fullboth current-value)
                                    (if (boundp 'old-fullscreen) old-fullscreen nil)
                                    (progn (setq old-fullscreen current-value)
                                           'fullboth)))))
;;; MARKING AND EDITING
;;; 
(add-to-list 'load-path "~/.emacs.d/vendor/expand-region.el/")
(add-to-list 'load-path "~/.emacs.d/vendor/multiple-cursors.el/")
(require 'expand-region)
(require 'multiple-cursors)
(require 'unbound) ;pkg
(global-set-keys
 '(;;; up AND out / down AND in, for convenience 
   ("C-<up>    " er/expand-region)
   ("C-<right> " er/expand-region)
   ("C-<down>  " er/contract-region)
   ("C-<left>  " er/contract-region)
   ;;; multiple cursors works well with expanded regions!
   ("M-<down>  " mc/mark-next-like-this)
   ("M-<up>    " mc/mark-previous-like-this)x
   ("M-@       " mc/mark-all-in-region) ;doubleplusgood
   ("C-c C-SPC " mc/mark-all-like-this)
   ("C-c C-a   " mc/edit-lines) ;region
   ;;; and regular awesomeness
   ("M-#       " align-regexp)          ;surprising how often
   ("C-\\      " align-regexp)
   ("C-c f     " vc-git-grep)           ;anything-git-grep broken :(
   ("C-c g     " anything-git-goto)))   ;oooh textmate

;;; LANGUAGE MODES
;;; mostly, set via packages
(defun set-mode-for-filename-patterns (mode filename-pattern-list)
  (mapcar (lambda (filename-pattern)
            (setq auto-mode-alist (cons (cons filename-pattern mode) auto-mode-alist)))
    filename-pattern-list))

(setq sgml-basic-offset 2)
(require 'slim-mode) ;; package
(set-mode-for-filename-patterns 'ruby-mode
  '("\\.rb$" "\\.rsel$" "\\.rhtml$" "\\.erb$" "\\.prawn$" 
    "\\.rake" "Rakefile$" "Gemfile$" "Capfile$"))

(add-to-list 'auto-mode-alist '("\\.eco\\'" . html-mode))
(add-to-list 'load-path "~/.emacs.d/vendor/coffee-mode")
(require 'coffee-mode)
(set-mode-for-filename-patterns 'coffee-mode '("\\.coffee" "Cakefile"))


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes (quote ("1f392dc4316da3e648c6dc0f4aad1a87d4be556c" 
                              "485737acc3bedc0318a567f1c0f5e7ed2dfde3fb" default))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
