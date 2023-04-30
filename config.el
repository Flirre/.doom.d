;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Filip Lindahl"
      user-mail-address "filip.g.lindahl@gmail.com")

(setq auth-sources '("~/.authinfo"))

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(when (eq system-type 'darwin)
  (setq doom-font (font-spec :family "VictorMono Nerd Font" :size 18 )
        doom-big-font (font-spec :family "VictorMono Nerd Font" :size 20 )))

(when (eq system-type 'gnu/linux)
  (setq doom-font (font-spec :family "VictorMono Nerd Font" :size 18 )
        doom-big-font (font-spec :family "VictorMono Nerd Font" :size 20 )))
;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-vibrant)
(setq fancy-splash-image "~/.doom.d/splash/doomEmacsDoomOne.svg")


;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/agenda/")
(setq org-archive-location "~/agenda/archives/%s_archive::")

(after! org
  :custom
  (setq org-fontify-done-headline t)
  (setq org-deadline-warning-days 7)
  (setq org-agenda-time-leading-zero t)
  (setq calendar-left-margin 12)
  (setq org-todo-keywords
        '((sequence "TODO(t)" "IN-PROGRESS(i)" "|" "DONE(d)" "CANCELED(c)")))
  (setq org-startup-folded 'fold)
  (custom-set-faces!
    '(org-done :strike-through t)
    '(org-headline-done :strike-through t)))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; Makes it so that no confirmation is needed to quit Emacs.
(setq confirm-kill-emacs nil)
;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;;
(dimmer-mode t)
(after! dimmer
  :custom
  (dimmer-configure-which-key)
  (dimmer-configure-magit)
  (dimmer-configure-org)
  (dimmer-configure-posframe))



(after! doom-modeline
  :custom
  (setq doom-modeline-vcs-max-length 36)
  (setq doom-modeline-buffer-encoding nil)
  (setq doom-modeline-buffer-file-name-style 'truncate-all)
  (setq doom-modeline-percent-position nil))

(after! company
  :custom
  (setq company-idle-delay 0.750))

(after! company-box
  (setq company-box-doc-delay 0))

(after! transient
  :custom
  (transient-define-prefix oht-transient-help ()
    "Transient for Helpful commands"
    [[("p" "At Point" helpful-at-point)]
     [("c" "Callable" helpful-callable)
      ("f" "Function" helpful-function)
      ("C" "Command" helpful-command)
      ("v" "Variable" helpful-variable)
      ("s" "Symbol" helpful-symbol)
      ("M" "Macro" helpful-macro)
      ("k" "Key" helpful-key)
      ("m" "Mode" helpful-mode)]
     [("u" "Update" helpful-update)
      ("V" "Visit Reference" helpful-visit-reference)
      ("K" "Kill Helpful Buffers" helpful-kill-buffers)]]))

(map!
 :after transient
 "C-h H"  #'oht-transient-help
 "C-h h"  #'oht-transient-help)

;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
;;
;; Override binding for C-s with helm-occur for convenience
;; (map!
;;  :after helm
;;  "C-s" #'helm-occur)
(map!
 :after ivy
 "C-s" #'swiper)

(map!
 :after counsel
 :map counsel-find-file-map
 [return] #'ivy-alt-done)

(map!
 "M-o" #'other-window)

(map!
 :map company-active-map
 "TAB" #'company-abort
 "<tab>" #'company-abort)

(map!
 :map global-map
 "<backtab>" #'company-capf
 "C-z" nil
 "C-x C-z" nil
 "<f18> r" #'undo-tree-redo
 "<f18> u" #'undo-tree-undo
 "<XF86Launch9> r" #'undo-tree-redo
 "<XF86Launch9> u" #'undo-tree-undo)

(add-hook! 'typescript-mode-hook 'prettier-js-mode)
(add-hook! 'typescript-tsx-mode-hook 'prettier-js-mode)
(add-hook! 'js2-mode-hook 'prettier-js-mode)
(add-hook! 'web-mode-hook 'prettier-js-mode)
(add-hook! 'rjsx-mode-hook 'prettier-js-mode)
(add-hook! 'json-mode-hook 'prettier-js-mode)

(after! 'magit-mode
  (add-hook! 'after-save-hook 'magit-after-save-refresh-status t))

(after! lsp-ui
  (setq lsp-ui-sideline-diagnostic-max-lines 2))

(when (eq system-type 'darwin)
  (setq
   ns-command-modifier 'control
   ns-option-modifier 'meta
   ns-control-modifier 'control
   ns-function-modifier 'hyper)
  (map!
   "M-8" (lambda () (interactive) (insert "["))
   "M-9" (lambda () (interactive) (insert "]"))
   "M-(" (lambda () (interactive) (insert "{"))
   "M-)" (lambda () (interactive) (insert "}"))))

;; A GitHub username for API authentication
(setq grip-github-user "flirre")
;; A GitHub password or auth token for API auth
;; (setq grip-github-password "password")

(after! treemacs
  (setq treemacs-git-mode 'deferred))

(use-package files
  :defer t
  :config
  (setq confirm-kill-processes nil))

(use-package paren
  :defer t
  :ensure nil
  :init (setq show-paren-delay 0.1)
  :config (show-paren-mode +1))

(setq flycheck-javascript-eslint-executable "eslint_d")
(setq prettier-js-command "prettier_d_slim")

(setq eslintd-fix-executable "eslint_d")

(add-hook 'typescript-tsx-mode-hook 'eslintd-fix-mode)
(add-hook 'typescript-mode-hook 'eslintd-fix-mode)
(add-hook 'web-mode-hook 'eslintd-fix-mode)

(setq magit-process-finish-apply-ansi-colors t)
(setq magit-process-popup-time 0)

(setq-hook! 'typescript-mode-hook +format-with-lsp nil)
(setq-hook! 'javascript-mode-hook +format-with-lsp nil)
(setq-hook! 'rjsx-mode-hook +format-with-lsp nil)


;; Function that tries to auto-expand YaSnippets
(after! yasnippet
  (defun my-yas-try-expanding-auto-snippets ()
    (when yas-minor-mode
      (let ((yas-buffer-local-condition ''(require-snippet-condition . auto)))
        (yas-expand))))
  (add-hook 'post-command-hook #'my-yas-try-expanding-auto-snippets))


;; accept completion from copilot and fallback to company
(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (("C-TAB" . 'copilot-accept-completion-by-word)
         ("C-<tab>" . 'copilot-accept-completion-by-word)
         :map copilot-completion-map
         ("<tab>" . 'copilot-accept-completion)
         ("TAB" . 'copilot-accept-completion)))
