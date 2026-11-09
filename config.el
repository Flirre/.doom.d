;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq user-full-name "Filip Lindahl"
      user-mail-address "filip.g.lindahl@gmail.com")

;; Some packages expect a POSIX shell. Interactive shells use fish.
(setq shell-file-name (executable-find "bash"))
(setq-default explicit-shell-file-name (executable-find "fish"))


;;; UI
;; ── Mermaid diagrams in org ──────────────────────────────────────────
;; Render mermaid src blocks to SVG via ob-mermaid + mermaid-cli (mmdc).
;; mmdc is installed via pacman (mermaid-cli); htmlLabels:false keeps node
;; labels as pure SVG text (foreignObject HTML breaks Emacs image display).
;; mmdc-emacs is a wrapper that injects xml:space="preserve" so librsvg
;; (Emacs's SVG renderer) keeps the spaces between per-word tspans.

(use-package! ob-mermaid
  :after org
  :config
  (setq ob-mermaid-cli-path "/home/filiplindahl/.doom.d/mmdc-emacs"
        ob-mermaid-default-config-file "/home/filiplindahl/.doom.d/mermaid-config.json"))

(after! org
  (defun +mermaid-render-all ()
    "Execute all mermaid src blocks in the current buffer."
    (interactive)
    (org-babel-map-src-blocks nil
      (when (string= lang "mermaid")
        (org-babel-execute-src-block))))

  (map! :map org-mode-map :localleader
    "m" #'+mermaid-render-all))


(defvar nice-fonts '("VictorMono Nerd Font" "JetBrainsMono Nerd Font" "FantasqueSansM Nerd Font"
                     "ComicShannsMono Nerd Font" "Iosevka Nerd Font" "Monofur Nerd Font"))
(defvar nice-font-size 21)
(defvar nice-font-size-big 28)
(defvar nice-themes '(doom-bluloco-light doom-nord-aurora doom-oksolar-light doom-outrun-electric
                      doom-laserwave doom-miramare doom-monokai-ristretto))

(+apply-random-font)
(setq doom-theme (seq-random-elt nice-themes)
      fancy-splash-image (file-name-concat doom-user-dir "splash/doomEmacsDoomOne.svg"))

;; Each clone of a repo, such as Shop.Web and Shop.Web-1 to Shop.Web-3, gets
;; its own frame theme, so that I always see which clone I edit.
(setq +repo-suffix-themes '(("-1" . doom-bluloco-light)
                            ("-2" . doom-outrun-electric)
                            ("-3" . doom-miramare)
                            (""   . doom-nord-aurora))
      +repo-suffix-theme-modes '(dired-mode magit-mode ghostel-mode))

(advice-add #'face-spec-recalc :around #'+frame-theme--recalc-a)
(add-hook! '(window-selection-change-functions window-buffer-change-functions)
           #'+repo-suffix-theme-h)

;; Emacs 31 and doom-themes make two gnus faces inherit from each other, so
;; `C-x 5 2' fails. This spec keeps the colors without inheritance (themes#875).
(after! gnus
  (face-spec-set 'gnus-group-news-low
                 '((((class color) (background dark))
                    :foreground "DarkTurquoise" :weight bold)
                   (((class color) (background light))
                    :foreground "DarkGreen" :weight bold)
                   (t :weight bold))
                 'face-defface-spec))

(after! which-key
  (setq which-key-max-description-length nil))


;;; Keys

(setq confirm-kill-emacs nil)

(when (featurep :system 'macos)
  (setq mac-command-modifier 'control
        mac-function-modifier 'hyper)
  (map! "M-7" (cmd! (insert "|"))
        "M-8" (cmd! (insert "["))
        "M-9" (cmd! (insert "]"))
        "M-(" (cmd! (insert "{"))
        "M-)" (cmd! (insert "}"))))

(map! "C-z"       nil
      "C-x C-z"   nil
      "C-c r"     #'randomize-theme-and-font
      "<f19>"     #'undo-tree-redo
      "<f18>"     #'undo-tree-undo
      "M-o"       #'other-window
      "M-<up>"    #'drag-stuff-up
      "M-<down>"  #'drag-stuff-down
      "M-<left>"  #'drag-stuff-left
      "M-<right>" #'drag-stuff-right)


;;; and LSP checkers

(after! lsp-mode
  (setq lsp-clients-typescript-prefer-use-project-ts-server t
        lsp-tailwindcss-server-version "0.14.26"
        lsp-tailwindcss-class-functions ["classNames" "cn" "clsx" "cva" "cx"]
        ;; Tailwind v4 puts `@theme', `@apply' and `@utility' in CSS files.
        lsp-css-lint-unknown-at-rules "ignore"
        ;; prettier formats the code, not eslint.
        lsp-eslint-format nil
        ;; The `web' module installs this server with the HTML and CSS servers.
        lsp-eslint-server-command
        (list "node"
              (expand-file-name
               (concat "npm/vscode-langservers-extracted/lib/node_modules/"
                       "vscode-langservers-extracted/lib/eslint-language-server/"
                       "eslintServer.js")
               lsp-server-install-dir)
              "--stdio"))
  ;; `next dev' rewrites .next all the time. Shop.Web/.next holds 7377 files.
  (dolist (re '("[/\\\\]\\.next[^/\\\\]*\\'"
                "[/\\\\]coverage\\'"
                "[/\\\\]playwright-report\\'"
                "[/\\\\]test-results\\'"
                "[/\\\\]storybook-static\\'"))
    (add-to-list 'lsp-file-watch-ignored-directories re))
  ;; A tailwindcss hover shows CSS through `css-mode', which loads eww and gnus.
  (doom-load-packages-incrementally '(gnus mm-url shr eww css-mode) t))

(after! lsp-ui
  (setq lsp-ui-sideline-enable nil))

;; The eslint server reports the same rules. One CLI run takes 12 s in Shop.Web.
(after! flycheck
  (setq-default flycheck-disabled-checkers '(javascript-eslint)))


;;; Formatting and compilation

;; Use only the project's prettier config, and not the Emacs indent settings.
(after! apheleia
  (setq apheleia-formatters-respect-indent-level nil)
  ;; `--parser=json' formats package.json differently from `prettier --write'.
  ;; Without the flag, `--stdin-filepath' selects the parser, as the CLI does.
  (setf (alist-get 'prettier-json apheleia-formatters)
        (remove "--parser=json" (alist-get 'prettier-json apheleia-formatters))))

(after! compile
  (add-to-list 'compilation-error-regexp-alist 'vitest)
  (add-to-list 'compilation-error-regexp-alist-alist
               '(vitest "^\\s-*❯\\s-+\\([^: \n]+\\):\\([0-9]+\\):\\([0-9]+\\)"
                 1 2 3)))


;;; Markdown

;; Show Markdown as rendered, and show the source of the element at point.
(add-hook 'markdown-ts-mode-hook #'markdown-ts-appear-mode)


;;; Performance

;; Each repo here uses Git, so `vc' does not probe for SVN and Hg on file open.
(setq vc-handled-backends '(Git))

;; Doom raises this only in `+lsp-optimization-mode', after the first server starts.
(setq read-process-output-max (* 1024 1024))

;; ESET scans each new .eln file on this Mac, and one load costs 270-400 ms.
(when (featurep :system 'macos)
  (setq doom-incremental-first-idle-timer 10.0
        doom-incremental-idle-timer 1.5))


;;; Projects

;; `SPC p p' shows the git branch of each project.
(after! marginalia
  (setf (alist-get 'project-file marginalia-annotators)
        '(+marginalia-annotate-project-file marginalia-annotate-project-file builtin none)))


;;; Terminal and coding agents

;; ghostel loads its module at load time. A package rebuild deletes the module
;; from the package directory, so keep it in Doom's data directory.
(setq ghostel-module-directory (file-name-concat doom-data-dir "ghostel/"))
(after! ghostel
  (setq ghostel-shell (executable-find "fish")
        ghostel-module-auto-install 'download))
(add-hook 'ghostel-mode-hook #'+terminal-glyph-setup-h)

(after! claude-code-ide
  (setq claude-code-ide-terminal-backend 'ghostel)
  (claude-code-ide-emacs-tools-setup))

(after! agent-shell
  (setq agent-shell-preferred-agent-config 'claude-code))

(map! "C-c C-'" #'claude-code-ide-menu)
(map! :leader
      (:prefix ("o c" . "coding agents")
       :desc "claude-code-ide menu" "c" #'claude-code-ide-menu
       :desc "agent-shell"          "a" #'agent-shell)
      (:prefix ("l" . "claude width")
       :desc "Half frame width" "h" #'+claude-code-ide-width-half
       :desc "Default width"    "d" #'+claude-code-ide-width-default))


;;; Magit and Azure DevOps

;; Color the current hunk in the faces of its language.
;; `+azdo-review-mode' colors all hunks in a small PR.
(after! magit
  (setq magit-diff-fontify-hunk t
        magit-diff-use-indicator-faces t))

(map! :leader :desc "Azure DevOps / review" "g A" #'+azdo-menu)


;;; Changes review

;; The review of the Changes mod of Claude Code, in a magit diff buffer.
(use-package! changes
  :commands changes
  :init
  (map! :leader :desc "Changes review" "g v" #'changes)
  ;; magit-status and magit-dispatch show the review only after changes loads.
  (after! magit (require 'changes)))
