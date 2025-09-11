;;; lsp-oxc.el --- lsp-mode OXC integration -*- lexical-binding: t; -*-

;; Copyright (C) 2025  Filip Lindahl

;; Author: Filip Lindahl
;; Keywords: languages

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; LSP client for OXC language server, providing fast JavaScript/TypeScript
;; linting through the oxc_language_server binary.
;;
;; The OXC project is a high-performance toolchain for JavaScript written in Rust.
;; This client provides integration with Emacs lsp-mode for the OXC language server.
;;
;; For more information about OXC, see: https://github.com/oxc-project/oxc

;;; Code:

(require 'lsp-mode)
(require 'lsp-protocol)
(require 'dash)
(require 'f)
(require 'ht)

(defgroup lsp-oxc nil
  "OXC language server group."
  :group 'lsp-mode
  :link '(url-link "https://github.com/oxc-project/oxc")
  :package-version '(lsp-mode . "9.0.0"))

(defcustom lsp-oxc-enable t
  "Controls whether OXC is enabled for JavaScript/TypeScript files."
  :type 'boolean
  :group 'lsp-oxc
  :package-version '(lsp-mode . "9.0.0"))

(defcustom lsp-oxc-server-command nil
  "Command to start OXC language server.
If nil, will attempt to find oxc_language_server automatically."
  :type '(choice (const nil) (repeat string))
  :group 'lsp-oxc
  :risky t
  :package-version '(lsp-mode . "9.0.0"))

(defcustom lsp-oxc-run "onType"
  "When to run the linter.
- \"onType\": Run on every keystroke (default)
- \"onSave\": Run only when file is saved"
  :type '(choice (const "onType") (const "onSave"))
  :group 'lsp-oxc
  :package-version '(lsp-mode . "9.0.0"))

(defcustom lsp-oxc-config-path nil
  "Path to oxlint configuration file.
If nil, will use default configuration discovery."
  :type '(choice (const nil) string)
  :group 'lsp-oxc
  :package-version '(lsp-mode . "9.0.0"))

(defcustom lsp-oxc-tsconfig-path nil
  "Path to TypeScript configuration file.
If nil, will use default TypeScript configuration discovery."
  :type '(choice (const nil) string)
  :group 'lsp-oxc
  :package-version '(lsp-mode . "9.0.0"))

(defcustom lsp-oxc-unused-disable-directives "allow"
  "How to handle unused disable directives.
- \"allow\": Allow unused disable directives (default)
- \"warn\": Warn about unused disable directives
- \"deny\": Error on unused disable directives"
  :type '(choice (const "allow") (const "warn") (const "deny"))
  :group 'lsp-oxc
  :package-version '(lsp-mode . "9.0.0"))

(defcustom lsp-oxc-flags nil
  "Special OXC language server flags.
An alist of flag names to values. Currently supported flags:
- \"disable_nested_config\": Disable nested configuration discovery
- \"fix_kind\": Type of fixes to apply (\"safe_fix\", \"safe_fix_or_suggestion\", etc.)"
  :type '(alist :key-type string :value-type string)
  :group 'lsp-oxc
  :package-version '(lsp-mode . "9.0.0"))

(defcustom lsp-oxc-working-directories []
  "Working directories for OXC.
A vector of working directory specifications. Each can be:
- A string path (absolute or relative to workspace)
- A plist with :mode key for special modes like \"auto\" or \"location\"
- A plist with :pattern key for glob patterns"
  :type '(lsp-repeatable-vector (choice string (plist :mode string) (plist :pattern string)))
  :group 'lsp-oxc
  :package-version '(lsp-mode . "9.0.0"))

(defun lsp-oxc--find-binary ()
  "Find the OXC language server binary.
Searches in the following order:
1. User-specified command in `lsp-oxc-server-command`
2. Local workspace node_modules/.bin/oxc_language_server
3. Global oxc_language_server in PATH"
  (or
   ;; 1. Use user-specified command if available
   (when lsp-oxc-server-command
     lsp-oxc-server-command)
   ;; 2. Look in workspace node_modules/.bin/
   (when-let* ((workspace-folder (lsp-find-session-folder (lsp-session) default-directory)))
     (let ((local-path (f-join workspace-folder "node_modules" ".bin" "oxc_language_server")))
       (when (f-exists? local-path)
         (list local-path))))
   ;; 3. Look in global PATH
   (when (executable-find "oxc_language_server")
     (list "oxc_language_server"))))

(defun lsp-oxc--has-config-p ()
  "Check if an oxlint configuration file exists in the workspace.
Looks for oxlintrc.json or .oxlintrc.json in the workspace root."
  (when-let* ((workspace-folder (lsp-find-session-folder (lsp-session) default-directory)))
    (--any? (f-exists? (f-join workspace-folder it))
            '("oxlintrc.json" ".oxlintrc.json"))))

(defun lsp-oxc--working-directory (workspace-folder current-file)
  "Find the appropriate working directory for CURRENT-FILE in WORKSPACE-FOLDER.
Returns the first matching directory from `lsp-oxc-working-directories`."
  (let* ((directories (-map (lambda (dir)
                              (cond
                               ((stringp dir)
                                (if (f-absolute? dir) dir (f-join workspace-folder dir)))
                               ((and (listp dir) (plist-get dir :pattern))
                                (let ((pattern (plist-get dir :pattern)))
                                  (when (not (f-absolute? pattern))
                                    (setq pattern (f-join workspace-folder pattern)))
                                  (f-glob pattern)))
                               ((and (listp dir) (plist-get dir :mode))
                                `(mode . ,(plist-get dir :mode)))
                               (t dir)))
                            (append lsp-oxc-working-directories nil)))
         (working-directory (-first (lambda (dir)
                                      (if (stringp dir)
                                          (f-ancestor-of-p dir current-file)
                                        dir))
                                    (-flatten directories))))
    (cond
     ((consp working-directory) `(:mode ,(cdr working-directory)))
     ((stringp working-directory) (list :directory working-directory))
     (t (list :mode "location")))))

(lsp-defun lsp-oxc--configuration (_workspace (&ConfigurationParams :items))
  "Handle workspace/configuration requests from OXC server.
Returns configuration for each requested scope."
  (->> items
       (seq-map (-lambda ((&ConfigurationItem :scope-uri?))
                  (-when-let* ((file (and scope-uri? (lsp--uri-to-path scope-uri?)))
                               (buffer (find-buffer-visiting file))
                               (workspace-folder (lsp-find-session-folder (lsp-session) file)))
                    (with-current-buffer buffer
                      (list :run lsp-oxc-run
                            :configPath lsp-oxc-config-path
                            :tsConfigPath lsp-oxc-tsconfig-path
                            :unusedDisableDirectives lsp-oxc-unused-disable-directives
                            :flags (or lsp-oxc-flags (ht))
                            :workingDirectory (lsp-oxc--working-directory workspace-folder file)
                            :workspaceFolder (list :uri (lsp--path-to-uri workspace-folder)
                                                   :name (f-filename workspace-folder)))))))
       (apply #'vector)))

(defun lsp-oxc--initialization-options ()
  "Generate initialization options for OXC server.
Returns settings as required by the OXC language server protocol."
  (when-let* ((workspace-folder (lsp-find-session-folder (lsp-session) default-directory)))
    (vector (ht ("workspaceUri" (lsp--path-to-uri workspace-folder))
                ("options" (ht ("run" lsp-oxc-run)
                              ("configPath" lsp-oxc-config-path)
                              ("tsConfigPath" lsp-oxc-tsconfig-path)
                              ("unusedDisableDirectives" lsp-oxc-unused-disable-directives)
                              ("flags" (or lsp-oxc-flags (ht)))))))))

(defun lsp-oxc--register-watchers (workspace)
  "Register file watchers for OXC configuration files in WORKSPACE.
Watches for changes to oxlintrc.json files to trigger re-linting."
  (lsp--server-register-capability
   (lsp-make-registration
    :id "oxc-config-watcher"
    :method "workspace/didChangeWatchedFiles"
    :register-options? (lsp-make-did-change-watched-files-registration-options
                        :watchers
                        `[,(lsp-make-file-system-watcher
                            :glob-pattern "**/.oxlintrc.json")
                          ,(lsp-make-file-system-watcher
                            :glob-pattern "**/oxlintrc.json")]))))

(defun lsp-oxc-fix-all ()
  "Apply all OXC fixes in the current buffer using code actions.
First tries to execute source.fixAll.oxc, then falls back to quickfix actions."
  (interactive)
  (cond
   ;; First try the specific source.fixAll.oxc action
   ((ignore-errors 
      (lsp-execute-code-action-by-kind "source.fixAll.oxc")
      t)
    (lsp--info "Applied source.fixAll.oxc fixes"))
   
   ;; Fall back to quickfix actions which OXC provides by default
   ((ignore-errors 
      (lsp-execute-code-action-by-kind "quickfix") 
      t)
    (lsp--info "Applied quickfix actions"))
   
   ;; Try the workspace command as final fallback
   ((lsp-workspaces)
    (lsp-oxc-apply-fixes))
   
   ;; No options available
   (t
    (when (called-interactively-p 'any)
      (lsp--warn "No OXC fix actions available for this buffer")))))

(defun lsp-oxc-debug-actions ()
  "Debug function to show available code actions from OXC server."
  (interactive)
  (let ((actions (lsp-code-actions-at-point)))
    (if actions
        (progn
          (lsp--info "Available OXC code actions:")
          (dolist (action actions)
            (lsp--info "- Kind: %s, Title: %s" 
                       (or (lsp:code-action-kind action) "no-kind")
                       (or (lsp:code-action-title action) "no-title"))))
      (lsp--info "No code actions available"))))

(defun lsp-oxc-apply-fixes ()
  "Apply OXC fixes using workspace command.
This is an alternative to code actions that uses the oxc.fixAll command."
  (interactive)
  (if (lsp-workspaces)
      (progn
        (lsp--info "Applying OXC fixes for buffer: %s" (lsp--buffer-uri))
        (lsp-send-execute-command
         "oxc.fixAll"
         (vector (ht ("uri" (lsp--buffer-uri))))))
    (lsp--warn "No active LSP workspace found")))

(defun lsp-oxc-server-command ()
  "Get the command to start the OXC language server.
Returns the server command or signals an error if not found."
  (or (lsp-oxc--find-binary)
      (user-error "Could not find oxc_language_server binary. Please install the oxlint package or set lsp-oxc-server-command")))

(lsp-register-client
 (make-lsp-client
  :new-connection (lsp-stdio-connection
                   (lambda () (lsp-oxc-server-command))
                   (lambda () (lsp-oxc--find-binary)))
  :activation-fn (lambda (filename &optional _)
                   "Activate OXC language server for supported file types when enabled."
                   (and lsp-oxc-enable
                        (lsp-oxc--has-config-p)
                        (string-match-p (rx (one-or-more anything) "."
                                            (or "ts" "js" "jsx" "tsx" "mts" "cts" "mjs" "cjs") eos)
                                        filename)))
  :priority -1
  :completion-in-comments? nil
  :add-on? t
  :multi-root t
  :initialization-options (lambda () (lsp-oxc--initialization-options))
  :request-handlers (ht ("workspace/configuration" #'lsp-oxc--configuration))
  :server-id 'oxc
  :initialized-fn (lambda (workspace)
                    "Set up file watchers and other initialization tasks."
                    (with-lsp-workspace workspace
                      (lsp-oxc--register-watchers workspace)))))

(lsp-consistency-check lsp-oxc)

(provide 'lsp-oxc)
;;; lsp-oxc.el ends here
