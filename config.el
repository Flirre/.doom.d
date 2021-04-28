;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Filip Lindahl"
      user-mail-address "filip.g.lindahl@gmail.com")

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
  (setq doom-font (font-spec :family "FantasqueSansMono Nerd Font" :size 18 )
        doom-big-font (font-spec :family "FantasqueSansMono Nerd Font" :size 22 )))

(when (eq system-type 'gnu/linux)
  (setq doom-font (font-spec :family "FantasqueSansMono Nerd Font" :size 18 )
        doom-big-font (font-spec :family "FantasqueSansMono Nerd Font" :size 22 )))
;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-molokai)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/agenda/")
(setq org-archive-location "~/agenda/archives/%s_archive::")
(setq org-deadline-warning-days 7)
(setq org-agenda-time-leading-zero t)
(setq calendar-left-margin 12)
(setq org-todo-keywords
      '((sequence "TODO(t)" "IN-PROGRESS(i)" "|" "DONE(d)" "CANCELED(c)")))
(setq org-startup-folded 'fold)

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
(setq mac-command-modifier 'meta)
(setq mac-option-modifier 'super)

;;(after! dimmer
;;  (dimmer-configure-which-key)
;;  (dimmer-configure-helm)
;;  (dimmer-configure-magit)
;;  (dimmer-configure-org)
;;  (dimmer-configure-posframe)
;;  (dimmer-mode t))

(after! doom-modeline
  (setq doom-modeline-vcs-max-length 32))

(after! company
  (setq company-idle-delay 0.08))

(after! transient
  (transient-define-prefix oht-transient-window ()
    "Most commonly used window commands"
    [["Splits"
      ("s" "Horizontal" split-window-below)
      ("v" "Vertical"   split-window-right)
      ("b" "Balance"    balance-windows)
      ("f" "Fit"        fit-window-to-buffer)]
     ["Window"
      ("c" "Clone Indirect" clone-indirect-buffer)
      ("t" "Tear Off" tear-off-window)
      ("k" "Kill" delete-window)
      ("K" "Kill Buffer+Win"  kill-buffer-and-window)
      ("o" "Kill Others"  delete-other-windows)
      ("m" "Maximize" maximize-window)]
     ["Navigate"
      ("<left>"  "←" windmove-left  :transient t)
      ("<right>" "→" windmove-right :transient t)
      ("<up>"    "↑" windmove-up    :transient t)
      ("<down>"  "↓" windmove-down  :transient t)]
     ["Move"
      ("S-<left>"  "S-←" buf-move-left  :transient t)
      ("S-<right>" "S-→" buf-move-right :transient t)
      ("S-<up>"    "S-↑" buf-move-up    :transient t)
      ("S-<down>"  "S-↓" buf-move-down  :transient t)]
     ["Undo/Redo"
      ("s-z" "Winner Undo" winner-undo :transient t)
      ("s-Z" "Winner Redo" winner-redo :transient t)]])

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
      ("K" "Kill Helpful Buffers" helpful-kill-buffers)]])
  )

(map!
 :after transient
 "C-h H"  #'oht-transient-help
 "s-w" #'oht-transient-window)

;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
;;
;; Override binding for C-s with helm-occur for convenience
(map!
 :after helm
 "C-s" #'helm-occur)

(map!
 "M-o" #'other-window)

(setq vterm-always-compile-module t)
(setq display-line-numbers-type nil)
(use-package! tree-sitter
  :config
  (require 'tree-sitter-langs)
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))
(setq-hook! 'rjsx-mode-hook +format-with-lsp nil)
(setq-hook! 'js-mode-hook +format-with-lsp nil)
(setq-hook! 'js2-mode-hook +format-with-lsp nil)
(setq-hook! 'typescript-mode-hook +format-with-lsp nil)
(setq-hook! 'json-mode-hook +format-with-lsp nil)

(setq flycheck-javascript-eslint-executable "eslint_d")
(set-formatter! 'eslintd  "eslint_d --fix-to-stdout --stdin")
(setq-hook! 'js2-mode-hook +format-with 'eslintd)
(setq-hook! 'typescript-mode-hook +format-with 'eslintd)
