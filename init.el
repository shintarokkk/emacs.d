;;;;;;;;;;;;;;;;;;;;;
;; global settings ;;
;;;;;;;;;;;;;;;;;;;;;

;; My global key
(global-set-key "\M-g" 'goto-line)
(global-set-key "\C-^" 'backward-kill-word)

;; My global mode
(electric-pair-mode 1)

;; suppress warnings and errors popup in native compile
(setq native-comp-async-report-warnings-errors nil)

;; prohibit opening another buffer when "M-x shell"
(add-to-list 'display-buffer-alist
             '("^\\*shell\\*$" . (display-buffer-same-window)))

;; increase gabage collection (default is supposed to be 80 MB)
;; to successfully install doom-theme
(setq gc-cons-threshold (* gc-cons-threshold 10))

(add-to-list 'load-path (expand-file-name (concat user-emacs-directory "site-lisp")))
;; for rust-analyzer
(add-to-list 'exec-path (expand-file-name "~/.local/bin"))

;;;;;;;;;;;;;;;;;;;;;
;; package manager ;;
;;;;;;;;;;;;;;;;;;;;;

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))

;; (unless package-archive-contents (package-refresh-contents))
(unless (require 'use-package nil t)
  (package-initialize)
  (unless (package-installed-p 'use-package)
    (package-refresh-contents))
  (package-install 'use-package))

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; editing customization ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

(when t
  ;; does not allow to use hard tab.
  (setq-default indent-tabs-mode nil)
  )

;; 句読点をドット、カンマにする
;; 出典: https://sugawarayusuke.hatenablog.com/entry/2016/01/22/230346
(defun replace-dot-comma ()
  "s/。/．/g; s/、/，/g;する"
  (interactive)
  (let ((curpos (point)))
    (goto-char (point-min))
    (while (search-forward "。" nil t) (replace-match "．"))
    (goto-char (point-min))
    (while (search-forward "、" nil t) (replace-match "，"))
    (goto-char curpos)
    ))

;;;;;;;;;;;;;;;;;;;;;
;; editing helpers ;;
;;;;;;;;;;;;;;;;;;;;;

(use-package avy
  :ensure t
  ;; "C-:" does not work in terminal
  :bind (("C-k" . avy-goto-char-timer)
         ("C-M-k" . avy-goto-char-2)
         )
  :config
  (progn
    (setq avy-timeout-seconds 0.35)
    (setq avy-background t)
    ))

(use-package company
  :ensure t
  :config
  (global-company-mode)
  ;; avoid lower casing in plain text
  (setq company-dabbrev-downcase nil)
  (setq company-idle-delay 0.4)
  (setq company-minimum-prefix-length 2)
  (setq company-selection-wrap-around t)
  (define-key company-active-map (kbd "C-n") 'company-select-next)
  (define-key company-active-map (kbd "C-p") 'company-select-previous)
  (define-key company-search-map (kbd "C-n") 'company-select-next)
  (define-key company-search-map (kbd "C-p") 'company-select-previous)
  (define-key company-active-map (kbd "<tab>") 'company-complete-selection)
  )

(use-package flycheck
  :ensure t
  :init (global-flycheck-mode t)
  )

(use-package lsp-mode
  :ensure t
  :hook
  (c-mode . lsp-deferred)
  (c++-mode . lsp-deferred)
  (cmake-mode . lsp-deferred)
  (rust-mode . lsp-deferred)
  ;; somehow "lsp-deferred" doesn't work for nxml-mode
  (nxml-mode . lsp)
  :bind (("C-c r" . lsp-format-region)
         ("C-c b" . lsp-format-buffer))
  :custom
  (lsp-prefer-capf t)
  (lsp-rust-server 'rust-analyzer)
  (lsp-file-watch-threshold 5000)
  (lsp-clients-clangd-args
   '("--header-insertion=never"))
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

;;;;;;;;;;;;;;;;;;;;;
;; view customizer ;;
;;;;;;;;;;;;;;;;;;;;;

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

(use-package doom-themes
  :ensure t
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-one t)
  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  )

(use-package solarized-theme
  :ensure t
  :config
    ;; (load-theme 'solarized-light t)
  )

(use-package neotree
  :ensure t
  :config
  (bind-key [f8] 'neotree-toggle)
  (setq neo-hidden-regexp-list
        ;; '("^\\." "\\.pyc$" "~$" "^#.*#$" "\\.elc$" "\\.o$"))
        '("\\.pyc$" "~$" "^#.*#$" "\\.elc$" "\\.o$"
          "^\\.cache$"
          "^\\.catkin_tools$"
          "^\\.clangd$"
          "^\\.git$"
          "^\\.vscode$"))
  )

(use-package rainbow-delimiters
  :ensure t
  :config
  (progn
    (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))
  )

(use-package tree-sitter
  :ensure t
  :hook
  (c-mode . tree-sitter-mode)
  (c-mode . tree-sitter-hl-mode)
  (c++-mode . tree-sitter-mode)
  (c++-mode . tree-sitter-hl-mode)
  (rust-mode . tree-sitter-mode)
  (rust-mode . tree-sitter-hl-mode)
  (python-mode . tree-sitter-mode)
  (python-mode . tree-sitter-hl-mode)
  )

(use-package tree-sitter-langs
  :ensure t
  )

;;;;;;;;;;;;;;;;;;;;
;; language modes ;;
;;;;;;;;;;;;;;;;;;;;

(add-hook 'c-mode-hook
          (lambda ()
            (setq c-basic-offset 4)
            (c-set-offset 'inextern-lang 0))
          )

(add-hook 'tex-mode-hook
          '(lambda ()
             (add-hook 'before-save-hook 'replace-dot-comma nil 'make-it-local)
             ))

;; xml-mode
(add-to-list 'auto-mode-alist '("\\.launch\\'" . nxml-mode))
(add-to-list 'auto-mode-alist '("\\.urdf\\'" . nxml-mode))
(add-to-list 'auto-mode-alist '("\\.sdf\\'" . nxml-mode))
(add-to-list 'auto-mode-alist '("\\.srdf\\'" . nxml-mode))
(add-to-list 'auto-mode-alist '("\\.xacro\\'" . nxml-mode))

(use-package cargo
  :ensure t
  :hook (rust-mode . cargo-minor-mode)
  )

(use-package cmake-mode
  :ensure t
  )

(use-package google-c-style
  :ensure t
  :hook
  (c++-mode . google-set-c-style)
  :config
  (c-set-offset 'inextern-lang 0)
  )

(use-package lsp-pyright
  :ensure t
  :hook (python-mode . (lambda ()
                         (require 'lsp-pyright)
                         (lsp)))
  )

(setq-default nxml-slash-auto-complete-flag t)

(use-package python-black
  :ensure t
  :after python
  )

(use-package rust-mode
  :ensure t
  :custom rust-format-on-save t
  )

(use-package yaml-mode
  :ensure t
  :config
  (progn
    (add-to-list 'auto-mode-alist '("\\.ya?ml\\'" . yaml-mode))
    )
  )
