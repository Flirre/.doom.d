;;; autoload/claude.el -*- lexical-binding: t; -*-

;;; Spinner glyphs
;; claude-code spinner glyphs fall back to a taller font, and the text moves.
;; The display table shows each glyph as one ASCII character.

;;;###autoload
(defun +terminal-glyph-setup-h ()
  "Show the claude-code spinner glyphs as ASCII in this terminal buffer."
  (let ((tbl (or buffer-display-table (setq buffer-display-table (make-display-table)))))
    (dolist (pair
             '((#x273B . ?*) ; ✻ TEARDROP-SPOKED ASTERISK
               (#x273D . ?*) ; ✽ HEAVY TEARDROP-SPOKED ASTERISK
               (#x2722 . ?+) ; ✢ FOUR TEARDROP-SPOKED ASTERISK
               (#x2736 . ?+) ; ✶ SIX-POINTED BLACK STAR
               (#x2733 . ?*) ; ✳ EIGHT SPOKED ASTERISK
               (#x00B7 . ?.) ; · MIDDLE DOT
               (#x2022 . ?.) ; • BULLET
               (#x25CF . ?.) ; ● BLACK CIRCLE
               (#x2219 . ?.) ; ∙ BULLET OPERATOR
               ;; Circle spinner
               (#x25D0 . ?o) ; ◐ LEFT HALF BLACK CIRCLE
               (#x25D1 . ?o) ; ◑ RIGHT HALF BLACK CIRCLE
               (#x25D2 . ?o) ; ◒ LOWER HALF BLACK CIRCLE
               (#x25D3 . ?o) ; ◓ UPPER HALF BLACK CIRCLE
               (#x25CB . ?o) ; ○ WHITE CIRCLE
               (#x25CC . ?o) ; ◌ DOTTED CIRCLE
               (#x25CD . ?o) ; ◍ CIRCLE WITH VERTICAL FILL
               (#x25CE . ?o) ; ◎ BULLSEYE
               (#x25EF . ?o) ; ◯ LARGE CIRCLE
               (#x25E6 . ?.) ; ◦ WHITE BULLET
               (#x26AA . ?o) ; ⚪ MEDIUM WHITE CIRCLE
               (#x26AB . ?o) ; ⚫ MEDIUM BLACK CIRCLE
               ;; Message bullets
               (#x23FA . ?*) ; ⏺ BLACK CIRCLE FOR RECORD
               (#x25C9 . ?*) ; ◉ FISHEYE
               (#x25C8 . ?*) ; ◈ WHITE DIAMOND CONTAINING BLACK SMALL DIAMOND
               (#x25A3 . ?*) ; ▣ WHITE SQUARE CONTAINING BLACK SMALL SQUARE
               (#x25A0 . ?*) ; ■ BLACK SQUARE
               (#x25A1 . ?*) ; □ WHITE SQUARE
               (#x25FC . ?*) ; ◼ BLACK MEDIUM SQUARE
               (#x25FB . ?*) ; ◻ WHITE MEDIUM SQUARE
               (#x25FE . ?*) ; ◾ BLACK MEDIUM SMALL SQUARE
               (#x25FD . ?*) ; ◽ WHITE MEDIUM SMALL SQUARE
               (#x2B1B . ?*) ; ⬛ BLACK LARGE SQUARE
               (#x2B1C . ?*) ; ⬜ WHITE LARGE SQUARE
               ;; Status markers
               (#x2713 . ?v) ; ✓ CHECK MARK
               (#x2714 . ?v) ; ✔ HEAVY CHECK MARK
               (#x2717 . ?x) ; ✗ BALLOT X
               (#x2718 . ?x) ; ✘ HEAVY BALLOT X
               (#x2139 . ?i) ; ℹ INFORMATION SOURCE
               (#x26A0 . ?!))) ; ⚠ WARNING SIGN
      (aset tbl (car pair) (vector (cdr pair))))))


;;; Window width

(defvar +claude-code-ide-default-width 100
  "The default body width of the Claude Code side window, as upstream sets it.")

(defun +claude-code-ide--window ()
  "Return the live window that shows a Claude Code session, or nil."
  (cl-find-if (lambda (win)
                (string-prefix-p "*claude-code[" (buffer-name (window-buffer win))))
              (window-list)))

(defun +claude-code-ide-set-width (target)
  "Set the body width of the Claude Code side window to TARGET columns.
Later sessions use the same width, and an open window resizes now."
  (setq claude-code-ide-window-width target)
  (when-let* ((win (+claude-code-ide--window)))
    ;; A side window keeps its size with `window-preserve-size'.
    (window-preserve-size win t nil)
    (ignore-errors (window-resize win (- target (window-body-width win)) t))
    (window-preserve-size win t t)))

;;;###autoload
(defun +claude-code-ide-width-half ()
  "Make the Claude Code window half as wide as the frame."
  (interactive)
  (+claude-code-ide-set-width (/ (frame-width) 2))
  (message "Claude Code width: %d columns" claude-code-ide-window-width))

;;;###autoload
(defun +claude-code-ide-width-default ()
  "Make the Claude Code window its default width again."
  (interactive)
  (+claude-code-ide-set-width +claude-code-ide-default-width)
  (message "Claude Code width: %d columns" claude-code-ide-window-width))
