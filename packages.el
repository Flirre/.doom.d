;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; `:config default' declares drag-stuff only without evil.
(package! drag-stuff :pin "6d06d846cd37c052d79acd0f372c13006aa7e7c8")

(package! claude-code-ide
  :recipe (:host github :repo "manzaltu/claude-code-ide.el")
  :pin "50a3d55262805d7207889ed429ff30da96fbf68b")

(package! agent-shell :pin "c788df02f071cc808c837435b65c8e72668b8e22")
(package! acp :pin "2959da5fa8657da17a78ac6ceef303a50e3e69de")
(package! shell-maker :pin "b28ee61a2533e408ed180662f83bb84fc8f84ba6")

;; The review of the Changes mod in magit.
;; With no .elc, an edit in ~/dev/changes takes effect at the next start.
(package! changes
  :recipe (:local-repo "~/dev/changes"
           :files ("emacs/*.el" (:exclude "emacs/*-test.el"))
           :build (:not compile)))

(package! markdown-ts-appear :pin "d740ad4f59b8b34ea27a93a2b3b98fbdaf0cd467")

;; Structural / side-by-side diffs for the Azure DevOps review flow (opt-in view).
(package! difftastic :pin "98c61e7dfac8d1ad4451423395da6bc14caa41df")

;; Review git diffs like a PR: counts, file tree, inline diffs, and comments.
(package! diff-review
  :recipe (:host github :repo "xiaoxinghu/diff-review")
  :pin "49cba292bb933e2a1a90f61145e29311636544ae")

;; `:tools lookup' declares `request', but no Doom module and no installed
;; package ever loads it. It costs 7,645 B of the startup autoload file.
(package! request :disable t)

;; `:lang emacs-lisp' loads it with flycheck. It lints MELPA package headers.
(package! flycheck-package :disable t)

(package! ob-mermaid)
;; `:lang sh' uses it to complete commands in shell-script buffers through bash.
(package! bash-completion :disable t)
