;; Global Setting Key
;; prohibit opening another buffer when "M-x shell"
(setq pop-up-windows nil)

(global-set-key "\M-g" 'goto-line)
(global-set-key "\C-^" 'backward-kill-word)

;; increase gabage collection (default is supposed to be 80 MB)
;; to successfully install doom-theme
(setq gc-cons-threshold (* gc-cons-threshold 10))

(add-to-list 'load-path (expand-file-name (concat user-emacs-directory "site-lisp")))
(add-to-list 'exec-path (expand-file-name "~/.cargo/bin"))

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))

;; (unless package-archive-contents (package-refresh-contents))
(unless (require 'use-package nil t)
  (package-initialize)
  (unless (package-installed-p 'use-package)
    (package-refresh-contents))
  (package-install 'use-package))

;; color white spaces, tabs and zenkaku spaces
;; from https://cortyuming.hateblo.jp/entry/2016/07/17/160238
(progn
  (require 'whitespace)
  (setq whitespace-style
        '(face trailing tabs spaces spaces-mark tab-mark))
  (setq whitespace-display-mappings
        '(
          (space-mark ?\u3000 [?\u2423])
          (tab-mark ?\t [?\u00BB ?\t] [?\\ ?\t])
          ))
  (setq whitespace-trailing-regexp  "\\([ \u00A0]+\\)$")
  (setq whitespace-space-regexp "\\(\u3000+\\)")
  (set-face-attribute 'whitespace-trailing nil
                      :foreground "#cd2626"
                      :background "#cd2626"
                      :underline nil)
  (set-face-attribute 'whitespace-tab nil
                      :foreground "#8b5742"
                      :background "#8b5742"
                      :underline nil)
  (set-face-attribute 'whitespace-space nil
                      :foreground "#cd2626"
                      :background "#cd2626"
                      :underline nil)
  (global-whitespace-mode t)
  )

(when t
  ;; does not allow use hard tab.
  (setq-default indent-tabs-mode nil)
  )

;; xml-mode
(add-to-list 'auto-mode-alist '("\\.launch" . nxml-mode))
(add-to-list 'auto-mode-alist '("\\.urdf" . nxml-mode))
(add-to-list 'auto-mode-alist '("\\.srdf" . nxml-mode))
(add-to-list 'auto-mode-alist '("\\.xacro" . nxml-mode))

(use-package yaml-mode
  :ensure t
  :config
  (progn
    (add-to-list 'auto-mode-alist '("\\.ya?ml$" . yaml-mode))
  ))

(use-package google-c-style
  :ensure t
  :config
  (progn
    (add-hook 'c-mode-hook 'google-set-c-style)
    (add-hook 'c++-mode-hook 'google-set-c-style)
    ))

(use-package flycheck
  :ensure t
  :init (global-flycheck-mode t)
  )

(use-package company
  :ensure t
  :config
  (global-company-mode)
  (setq company-idle-delay 0.1)
  (setq company-minimum-prefix-length 3)
  (setq company-selection-wrap-around t)
  (define-key company-active-map (kbd "C-n") 'company-select-next)
  (define-key company-active-map (kbd "C-p") 'company-select-previous)
  (define-key company-search-map (kbd "C-n") 'company-select-next)
  (define-key company-search-map (kbd "C-p") 'company-select-previous)
  (define-key company-active-map (kbd "<tab>") 'company-complete-selection)
  )

;; you need lsp-servers for each language
;; sometimes you need to run "M-x lsp" by hand?
;; C/C++ -> $ sudo apt install clangd
;; python(pyls) -> $ pip3 install python-language-server --user
;; python(pyright) -> $ npm install -g pyright
(use-package lsp-mode
  :ensure t
  :hook ((python-mode c-mode c++-mode rust-mode) . lsp)
  :bind (("C-c r" . lsp-format-region)
         ("C-c b" . lsp-format-buffer))
  :custom
  (lsp-prefer-capf t)
  (lsp-rust-server 'rust-analyzer)
  :commands lsp
  )

(use-package lsp-ui
  :ensure t
  :after flycheck
  :commands lsp-ui-mode
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-enable t)
  (lsp-ui-doc-delay 1.0)
  (lsp-ui-doc-header t)
  ;; (lsp-ui-doc-use-webkit t)
  (lsp-ui-doc-use-childframe t)
  )

;; pyrightは型ヒントしてくれるがnp.matrixでエラー出したりと微妙？
(use-package lsp-pyright
  :ensure t
  :hook (python-mode . (lambda ()
                         (require 'lsp-pyright)
                         (lsp)))
  )

(use-package python-black
  :ensure t
  :after python
  )

(use-package euslisp-mode
  :ensure t
  :config
  (progn
    (add-to-list 'auto-mode-alist '("\\.l\\'" . euslisp-mode))
    (add-to-list 'interpreter-mode-alist '("roseus" . euslisp-mode))
    ))

(use-package avy
  :ensure t
  ;; "C-:" does not work in terminal
  :bind (("C-k" . avy-goto-char-timer)
         ("C-M-k" . avy-goto-char-2)
         )
  :config
  (progn
    (setq avy-timeout-seconds 0.4)
    (setq avy-background t)
    ))

(use-package neotree
  :ensure t
  :config
  (bind-key [f8] 'neotree-toggle)
  )

(use-package all-the-icons
  :ensure t
  )

(use-package doom-themes
  :ensure t
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-one t)
  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)

  ;; Enable custom neotree theme (all-the-icons must be installed!)
  (doom-themes-neotree-config)
  )

(use-package rust-mode
  :ensure t
  :custom rust-format-on-save t
  )

(use-package cargo
  :ensure t
  :hook (rust-mode . cargo-minor-mode)
  )

(use-package cmake-mode
  :ensure t
  )

(use-package slime
  :ensure t
  :init
  (load (expand-file-name "~/.quicklisp/slime-helper.el"))
  :config
  (setq inferior-lisp-program "sbcl")
  )

;; TODO: hydraの導入

;; TODO: yasnippet、またsnippetの例(https://github.com/AndreaCrotti/yasnippet-snippets)の導入

(add-hook 'rust-mode-hook
          (lambda ()
            (electric-pair-mode 1))
          )

(add-hook 'c-mode-hook
          (lambda ()
            (electric-pair-mode 1))
          )

(add-hook 'c++-mode-hook
          (lambda ()
            (electric-pair-mode 1))
          )

(add-hook 'python-mode-hook
          (lambda ()
            (electric-pair-mode 1))
          )

(add-hook 'cmake-mode-hook
          (lambda ()
            (electric-pair-mode 1))
          )

