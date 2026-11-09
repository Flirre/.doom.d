;;; autoload/themes.el -*- lexical-binding: t; -*-

;;;###autoload
(defun +apply-random-font ()
  "Set `doom-font' and `doom-big-font' to a random font from `nice-fonts'.
Return the font family."
  (let ((family (seq-random-elt nice-fonts)))
    (setq doom-font (font-spec :family family :size nice-font-size)
          doom-big-font (font-spec :family family :size nice-font-size-big))
    family))

;;;###autoload
(defun randomize-theme-and-font ()
  "Switch to a random theme from `nice-themes' and a random font from `nice-fonts'."
  (interactive)
  (let ((family (+apply-random-font))
        (theme (seq-random-elt nice-themes)))
    ;; `load-theme' keeps the current themes enabled. `disable-theme' changes
    ;; `custom-enabled-themes', so map over a copy.
    (mapc #'disable-theme (copy-sequence custom-enabled-themes))
    (setq doom-theme theme)
    (load-theme theme t)
    (doom/reload-font)
    (message "Randomized theme and font to %s / %s" theme family)))


;;; Frame themes
;; A frame theme applies to one frame and to its child frames (corfu popups).
;; A hash table holds the themes, because `frame-parameter' is too slow here.

(defvar +frame-theme--themes (make-hash-table :test #'eq :weakness 'key)
  "A hash table that maps each frame with a frame theme to that theme.")

(defun +frame-theme--of (frame)
  "Return the frame theme of FRAME, or nil when FRAME uses the global theme."
  (when (frame-live-p frame)
    (or (gethash frame +frame-theme--themes)
        (and (frame-parent frame)
             (gethash (frame-parent frame) +frame-theme--themes)))))

(defun +frame-theme--specs (theme)
  "Return a hash table that maps each face to its spec in THEME."
  (let ((settings (get theme 'theme-settings))
        (cache (get theme '+frame-theme--specs)))
    ;; Emacs adds each new setting at the front of the list. A different
    ;; first cons therefore means that the theme changed after the last call.
    (if (and cache (eq (car cache) settings))
        (cdr cache)
      (let ((specs (make-hash-table :test #'eq)))
        (dolist (setting settings)
          (when (eq (car setting) 'theme-face)
            (puthash (nth 1 setting) (nth 3 setting) specs)))
        (put theme '+frame-theme--specs (cons settings specs))
        specs))))

;;;###autoload
(defun +frame-theme--recalc-a (fn face frame)
  "Calculate FACE on FRAME from the frame theme of FRAME, when it has one."
  (let ((theme (+frame-theme--of frame)))
    (if (not theme)
        (funcall fn face frame)
      (while (get face 'face-alias)
        (setq face (get face 'face-alias)))
      ;; Doom keeps `doom-font' in the `user' entry, so keep that entry.
      (let ((user (assq 'user (get face 'theme-face)))
            (spec (gethash face (+frame-theme--specs theme))))
        (cl-letf (((get face 'theme-face)
                   (delq nil (list user (and spec (list theme spec))))))
          (funcall fn face frame))))))

(defun +frame-theme--recalc-frame (frame)
  "Calculate each face on FRAME again."
  ;; `default' comes first. Its background sets the `background-mode' that
  ;; the specs of the other faces test.
  (condition-case err
      (face-spec-recalc 'default frame)
    (error (message "+frame-theme: %s" (error-message-string err))))
  (frame-set-background-mode frame t)
  ;; This skips a face with a bad spec, and it keeps the attributes that code
  ;; set for all frames, such as the transparent diff-hl backgrounds.
  (face-set-after-frame-default frame))

;;;###autoload
(defun +frame-theme-apply (theme &optional frame)
  "Apply THEME to FRAME and to the child frames of FRAME.
FRAME defaults to the selected frame. The other frames keep the global theme."
  (interactive
   (list (intern (completing-read
                  "Theme for this frame: "
                  (mapcar #'symbol-name (custom-available-themes))))))
  (let ((frame (or frame (selected-frame))))
    (unless (custom-theme-p theme)
      ;; doom-nord-aurora has no `lexical-binding' cookie. Without this
      ;; binding, Emacs 31 opens a *Warnings* window when it loads the theme.
      (let ((warning-inhibit-types '((files missing-lexbind-cookie))))
        (load-theme theme t t)))
    (puthash frame theme +frame-theme--themes)
    (dolist (f (frame-list))
      (when (or (eq f frame) (eq (frame-parent f) frame))
        (+frame-theme--recalc-frame f)))))


;;; A frame theme for each clone of a repo

(defvar +repo-suffix-themes nil
  "An alist that maps each suffix of a repo name to a frame theme.
The first suffix that ends the repo name applies, so keep \"\" last.")

(defvar +repo-suffix-theme-modes nil
  "The major modes, in addition to file buffers, whose repo sets the theme.")

(defun +repo-suffix-theme (buffer)
  "Return the theme for the repo of BUFFER.
Return nil when BUFFER does not visit a file and its mode is not in
`+repo-suffix-theme-modes', or when BUFFER is not in a repo."
  (with-current-buffer buffer
    (when-let* (((or (buffer-file-name (buffer-base-buffer))
                     (derived-mode-p +repo-suffix-theme-modes)))
                (dir default-directory)
                ((not (file-remote-p dir)))
                (root (locate-dominating-file dir ".git")))
      (alist-get (file-name-nondirectory (directory-file-name root))
                 +repo-suffix-themes nil nil #'string-suffix-p))))

;;;###autoload
(defun +repo-suffix-theme-h (frame)
  "Apply the theme of the repo in the selected window of FRAME.
A child frame uses the theme of its parent frame, so skip it."
  (let ((window (frame-selected-window frame)))
    (unless (or (frame-parent frame) (window-minibuffer-p window))
      (when-let* ((theme (+repo-suffix-theme (window-buffer window))))
        (unless (eq theme (+frame-theme--of frame))
          (+frame-theme-apply theme frame))))))
