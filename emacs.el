(add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
(add-to-list 'default-frame-alist '(ns-appearance . dark))

(use-package zerodark-theme
  :demand t
  :config
  (progn
    (when (window-system)
      (load-theme 'zerodark t)
      (setq frame-title-format '(buffer-file-name "%f" ("%b"))))))

(defun zerodark-setup-modeline-format-custom ()
  "Setup the mode-line format for zerodark."
  (interactive)
  (require 'flycheck)
  (require 'magit)
  (require 'all-the-icons)
  (let ((class '((class color) (min-colors 89)))
	(light (if (true-color-p) "#ccd4e3" "#d7d7d7"))
	(comment (if (true-color-p) "#687080" "#707070"))
	(purple "#c678dd")
	(mode-line (if "#1c2129" "#222222")))
    (custom-theme-set-faces
     'zerodark

     ;; Mode line faces
     `(mode-line ((,class (:background ,mode-line
				       :height 0.9
				       :foreground ,light
				       :box ,(when zerodark-use-paddings-in-mode-line
					       (list :line-width 4 :color mode-line))))))
     `(mode-line-inactive ((,class (:background ,mode-line
						:height 0.9
						:foreground ,comment
						:box ,(when zerodark-use-paddings-in-mode-line
							(list :line-width 4 :color mode-line))))))
     `(anzu-mode-line ((,class :inherit mode-line :foreground ,purple :weight bold)))
     ))
(setq-default mode-line-format
		`("%e"
		  " "
		  ,zerodark-modeline-ro " "
		  ,zerodark-buffer-coding
		  mode-line-frame-identification " "
		  " "
		  ,mode-line-modified
		  " "
		  ,zerodark-modeline-buffer-identification
		  ,zerodark-modeline-position
		  ,(if zerodark-theme-display-vc-status
		       zerodark-modeline-vc
		     "")
		  "  "
		  (:eval (zerodark-modeline-flycheck-status))
		  "  " mode-line-modes mode-line-misc-info mode-line-end-spaces
		  ))
)
(when (window-system)
  (zerodark-setup-modeline-format-custom))

; (setq-default mode-line-format
;         (list
;          mode-line-modified
;          " "
;          "%l"
;          " "
;          mode-line-buffer-identification
;          " "
;          '(vc-mode vc-mode)
;          ))

(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

(setq ring-bell-function 'ignore)
(setq inhibit-startup-message t)
(setq indo-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode 1)

(defalias 'list-buffers 'ibuffer)

(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

(setq make-backup-file nil)
(setq auto-save-default nil)

(defalias 'yes-or-no-p 'y-or-n-p)

(use-package which-key
  :ensure t
  :init
  (which-key-mode))

(use-package org-bullets
  :ensure t
  :config
  (add-hook 'org-mode-hook(lambda () (org-bullets-mode 1))))

(use-package ace-window
  :ensure t
  :init
  (progn
    (global-set-key [remap other-window] 'ace-window)))

(add-hook 'prog-mode-hook
          (lambda ()
            (setq-local bidi-display-reordering nil)))

(defvar my-term "/usr/local/bin/fish")
(defadvice ansi-term (before force-bash)
  (interactive (list my-term)))
(ad-activate 'ansi-term)

(use-package ivy
  :ensure t
  :diminish (ivy-mode)
  :bind (("C-x b" . ivy-switch-buffer))
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq ivy-display-style 'fancy))

(use-package counsel
  :ensure t
  )

(use-package swiper
  :ensure t
  :bind (("C-s" . swiper)
   ("C-r" . swiper)
   ("C-c C-r" . ivy-resume)
   ("M-x" . counsel-M-x))
  :config
  (progn
    (ivy-mode 1)
    (setq ivy-use-virtual-buffers t)
    (setq enable-recursive-minibuffers t)
    (global-set-key (kbd "C-x C-f") 'counsel-find-file)
    (define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history)))

(use-package projectile
  :ensure t
  :config
  (projectile-global-mode)
  (setq projectile-completion-system 'ivy))

(use-package counsel-projectile
  :ensure t
  :config
  (counsel-projectile-mode))

(projectile-mode +1)
(define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)

(use-package ag
  :ensure t
  )

(use-package company
  :ensure t
  :init (progn
        (add-hook 'prog-mode-hook 'company-mode))
  :config
  (progn
    ;; Use Company for completion
    (bind-key [remap completion-at-point] #'company-complete company-mode-map)

    (setq company-tooltip-align-annotations t
          ;; Easy navigation to candidates with M-<n>
          company-show-numbers t)
    (setq company-dabbrev-downcase nil))
  :diminish company-mode)

;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)

;; some delay settings, fix it later
(setq company-dabbrev-downcase 0)
(setq company-idle-delay 0)

(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

(setq exec-path (append exec-path '("~/.nvm/versions/node/v8.11.3/bin")))
(setq exec-path (append exec-path '("/usr/local/bin")))

(use-package typescript-mode
  :ensure t
  :config
  (setq
   typescript-indent-level 2
   typescript-auto-indent-flag 0))

(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (setq tide-tsserver-executable "node_modules/.bin/tsserver")
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
  ;; company is an optional dependency. You have to
  ;; install it separately via package-install
  ;; `M-x package-install [ret] company`
  (company-mode +1))

(use-package tide
  :ensure t
  :after (typescript-mode company flycheck)
  :hook ((typescript-mode . tide-setup)
         (typescript-mode . tide-hl-identifier-mode)
   (before-save . tide-format-before-save)))

(use-package magit
    :ensure t
    :bind ("C-x g" . magit-status))

(use-package markdown-mode
  :ensure t
  :defer 1
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))

(defun config-reload ()
  "Reloads ~/.emacs.d/config.org at runtime"
  (interactive)
  (org-babel-load-file (expand-file-name "~/.emacs.d/emacs.org")))
(global-set-key (kbd "C-c r") 'config-reload)
