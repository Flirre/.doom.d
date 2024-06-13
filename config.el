;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Filip Lindahl"
      user-mail-address "filip.g.lindahl@gmail.com")

(setq auth-sources '("~/.authinfo"))

(setq nice-fonts '("VictorMono Nerd Font" "JetBrainsMono Nerd Font" "FantasqueSansM Nerd Font" "CaskaydiaCove Nerd Font" "ComicShannsMono Nerd Font" "Iosevka Nerd Font" "Monofur Nerd Font"))
(setq font-sizes '(("VictorMono Nerd Font" . 21) ("JetBrainsMono Nerd Font" . 21) ("FantasqueSansM Nerd Font" . 21) ("CaskaydiaCove Nerd Font" . 21) ("ComicShannsMono Nerd Font" . 21) ("Iosevka Nerd Font" . 21) ("Monofur Nerd Font" . 21)))
(setq font-sizes-big '(("VictorMono Nerd Font" . 28) ("JetBrainsMono Nerd Font" . 28) ("FantasqueSansM Nerd Font" . 28) ("CaskaydiaCove Nerd Font" . 28) ("ComicShannsMono Nerd Font" . 28) ("Iosevka Nerd Font" . 28) ("Monofur Nerd Font" . 28)))
(setq nice-font (seq-random-elt nice-fonts))
(setq nice-font-size (cdr (assoc nice-font font-sizes)))
(setq nice-font-size-big (cdr (assoc nice-font font-sizes-big)))

(setq nice-themes '(doom-bluloco-light doom-nord-aurora doom-oksolar-light doom-outrun-electric doom-laserwave doom-miramare doom-monokai-ristretto))
(setq nice-theme (seq-random-elt nice-themes))

(defun randomize-theme-and-font ()
  (interactive)
  (setq nice-font (seq-random-elt nice-fonts))
  (setq nice-font-size (cdr (assoc nice-font font-sizes)))
  (setq nice-font-size-big (cdr (assoc nice-font font-sizes-big)))
  (setq nice-theme (seq-random-elt nice-themes))
  (setq doom-font (font-spec :family nice-font :size nice-font-size))
  (setq doom-big-font (font-spec :family nice-font :size nice-font-size-big))
  (setq doom-theme nice-theme)
  (load-theme nice-theme t)
  (message "Randomized theme and font to %s %s" nice-theme nice-font)
  (set-frame-font nice-font))


(setq doom-font (font-spec :family nice-font :size nice-font-size)
      doom-big-font (font-spec :family nice-font :size nice-font-size-big))
;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
                                        ;(setq doom-theme nice-theme)
                                        ;(setq doom-theme 'doom-nord-aurora)
;;(setq doom-theme 'doom-bluloco-light)
(setq doom-theme nice-theme)
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
  (setq company-idle-delay 0.250))

(after! company-box
  (setq company-box-doc-delay 0.1))

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
 "C-c r" #'randomize-theme-and-font
 "<f18> r" #'undo-tree-redo
 "<f18> u" #'undo-tree-undo
 "<XF86Launch9> r" #'undo-tree-redo
 "<XF86Launch9> u" #'undo-tree-undo)

(after! 'magit-mode
  (add-hook! 'after-save-hook 'magit-after-save-refresh-status t))

(after! lsp
  (setq lsp-auto-execute-action nil))

(after! lsp-ui
  (setq lsp-ui-sideline-diagnostic-max-lines 2)
  (setq lsp-ui-doc-use-webkit t)
  (setq lsp-headerline-breadcrumb-enable t)
  (setq lsp-headerline-breadcrumb-segments '(file symbols))
  :map lsp-ui-mode-map
  "C-<" #'lsp-ui-doc-show
  "C->" #'lsp-ui-doc-hide)

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

(setq magit-process-finish-apply-ansi-colors t)
(setq magit-process-popup-time 0)

(setq-hook! 'typescript-mode-hook +format-with-lsp nil)
(setq-hook! 'javascript-mode-hook +format-with-lsp nil)
(setq-hook! 'rjsx-mode-hook +format-with-lsp nil)
(setq-hook! 'json-mode-hook +format-with-lsp nil)


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


(defun kill-echo-area ()
  "Save the content of the echo area into the `kill-ring'."
  (interactive)
  (kill-new (with-current-buffer " *Echo Area 0*"
              (save-restriction
                (widen)
                (buffer-substring-no-properties (point-min) (point-max))))))
(map!
 :map typescript-mode-map
 :map typescript-tsx-mode-map
 :map rjsx-mode-map
 :map js2-mode-map
 :map web-mode-map
 "C-:" #'kill-echo-area)
