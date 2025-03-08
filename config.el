;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
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
  (set-frame-font nice-font)
  (doom/reload-font))


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

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
(when (eq system-type 'darwin)
  (setq
   mac-command-modifier 'control
   mac-option-modifier 'meta
   mac-control-modifier 'control
   mac-function-modifier 'hyper)
  (map!
   "M-7" (lambda () (interactive) (insert "|"))
   "M-8" (lambda () (interactive) (insert "["))
   "M-9" (lambda () (interactive) (insert "]"))
   "M-(" (lambda () (interactive) (insert "{"))
   "M-)" (lambda () (interactive) (insert "}"))
                                        ;"C-x M-(" 'shrink-window-horizontally
                                        ;"C-x M-)" 'enlarge-window-horizontally
   ))

(map!
 :map global-map
 "C-z" nil
 "C-x C-z" nil
 "C-c r" #'randomize-theme-and-font
 "<f19>" #'undo-tree-redo
 "<f18>" #'undo-tree-undo
 "<XF86Launch9> r" #'undo-tree-redo
 "<XF86Launch9> u" #'undo-tree-undo
 "M-o" #'other-window)

(setq confirm-kill-emacs nil)

;; accept completion from copilot and fallback to company
(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("<tab>" . 'copilot-accept-completion)
              ("TAB" . 'copilot-accept-completion)
              ("<backtab>" . 'copilot-accept-completion)
              ("C-TAB" . 'copilot-accept-completion-by-word)
              ("C-<tab>" . 'copilot-accept-completion-by-word)))

(use-package! copilot-chat
  :custom (setq copilot-chat-model "claude-3.7-sonnet"))

(defun lsp-booster--advice-json-parse (old-fn &rest args)
  "Try to parse bytecode instead of json."
  (or
   (when (equal (following-char) ?#)
     (let ((bytecode (read (current-buffer))))
       (when (byte-code-function-p bytecode)
         (funcall bytecode))))
   (apply old-fn args)))
(advice-add (if (progn (require 'json)
                       (fboundp 'json-parse-buffer))
                'json-parse-buffer
              'json-read)
            :around
            #'lsp-booster--advice-json-parse)

(defun lsp-booster--advice-final-command (old-fn cmd &optional test?)
  "Prepend emacs-lsp-booster command to lsp CMD."
  (let ((orig-result (funcall old-fn cmd test?)))
    (if (and (not test?)                             ;; for check lsp-server-present?
             (not (file-remote-p default-directory)) ;; see lsp-resolve-final-command, it would add extra shell wrapper
             lsp-use-plists
             (not (functionp 'json-rpc-connection))  ;; native json-rpc
             (executable-find "emacs-lsp-booster"))
        (progn
          (message "Using emacs-lsp-booster for %s!" orig-result)
          (cons "emacs-lsp-booster" orig-result))
      orig-result)))
(advice-add 'lsp-resolve-final-command :around #'lsp-booster--advice-final-command)

;; LSP-mode: How do I force lsp-mode to forget the workspace folders for multi root servers so the workspace folders are added on demand?
;; https://emacs-lsp.github.io/lsp-mode/page/faq/#how-do-i-force-lsp-mode-to-forget-the-workspace-folders-for-multi-root-servers-so-the-workspace-folders-are-added-on-demand
(advice-add 'lsp :before (lambda (&rest _args) (eval '(setf (lsp-session-server-id->folders (lsp-session)) (ht)))))


(setq shell-file-name (executable-find "bash"))
(setq-default vterm-shell (executable-find "fish"))
(use-package! drag-stuff
  :defer t
  :init
  (map! "M-<up>" #'drag-stuff-up
        "M-<down>" #'drag-stuff-down
        "M-<left>" #'drag-stuff-left
        "M-<right>" #'drag-stuff-right))

(setq which-key-max-description-length nil)


(setq shell-file-name (executable-find "bash"))
(setq-default vterm-shell (executable-find "fish"))

(setq-default explicit-shell-file-name (executable-find "fish"))


(after! apheleia
  (set-formatter! 'prettier
    '("apheleia-npx" "prettier" "--stdin-filepath" filepath)
    :modes '(typescript-mode rjsx-mode js2-mode web-mode json-mode typescript-tsx-mode typescript-ts-mode js-mode))
  (setq apheleia-formatters-respect-indent-level nil)
  (setq apheleia-formatters-respect-fill-column nil))

(defun kill-echo-area ()
  "Save the content of the echo area into the `kill-ring'."
  (interactive)
  (kill-new (with-current-buffer " *Echo Area 0*"
              (save-restriction
                (widen)
                (buffer-substring-no-properties (point-min) (point-max))))))
