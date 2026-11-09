;;; autoload/project.el -*- lexical-binding: t; -*-

(defun +project-git-branch (dir)
  "Return the git branch of the project in DIR, or the short hash of a detached HEAD.
In a linked worktree, `.git' is a file that names the gitdir with the HEAD file."
  (let* ((git (expand-file-name ".git" dir))
         (gitdir (cond ((file-directory-p git) git)
                       ((file-readable-p git)
                        (with-temp-buffer
                          (insert-file-contents git)
                          (when (looking-at "gitdir: \\(.+\\)")
                            (expand-file-name (match-string 1) dir))))))
         (head-file (and gitdir (expand-file-name "HEAD" gitdir))))
    (when (and head-file (file-readable-p head-file))
      (with-temp-buffer
        (insert-file-contents head-file)
        (cond ((looking-at "ref: refs/heads/\\(.+\\)") (match-string 1))
              ((looking-at "\\([a-f0-9]\\{7\\}\\)") (match-string 1)))))))

;;;###autoload
(defun +marginalia-annotate-project-file (cand)
  "Annotate a project directory with its git branch, and a file as marginalia does.
A project prompt shows absolute directories, and a file prompt relative files."
  (if-let* (((file-name-absolute-p cand))
            (branch (+project-git-branch (expand-file-name cand))))
      (marginalia--fields (branch :face 'marginalia-documentation))
    (marginalia-annotate-project-file cand)))
