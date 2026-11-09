;;; $DOOMDIR/cli.el -*- lexical-binding: t; -*-

;; Keep the variables of an AI agent session out of the envvar file.
(dolist (re '("^CLAUDE" "^ANTHROPIC_" "^AI_AGENT$" "^GIT_EDITOR$" "^MCP_"
              "^BAGGAGE$" "^USE_\\(LOCAL\\|STAGING\\)_OAUTH$" "^API_TIMEOUT_MS$"
              "^DISABLE_\\(AUTOUPDATER\\|MICROCOMPACT\\)$" "^COREPACK_ENABLE_AUTO_PIN$"
              "^NODE_USE_SYSTEM_CA$" "^NoDefaultCurrentDirectoryInExePath$"
              "^PYTHONDONTWRITEBYTECODE$" "^MallocNanoZone$" "^OSLogRateLimit$"))
  (add-to-list 'doom-env-deny re))
