# kamkanam

Git commit helper that generates commit messages from staged diffs with Gemini
and outputs a single-line summary with commit type and AI usage. If the AI
percentage is above the threshold, the commit message is prefixed with `REVIEW:`.

## Requirements

- Python 3
- Git
- Gemini API key

## Install

### Homebrew (tap)

```sh
brew tap nileshteji/kamkanam
brew install kamkanam
```

### Manual install

```sh
./install.sh
```

To install to a different prefix (example: `/usr/local`):

```sh
./install.sh /usr/local
```

This installs:

- `kamkanam` to `$prefix/bin/kamkanam`
- a global `commit-msg` hook at `~/.config/git/hooks/commit-msg`
- sets `git config --global core.hooksPath` to that hooks directory

If you already use `core.hooksPath`, set `KAMKANAM_FORCE=1` to override or
install the hook manually.

## Usage

Generate a commit message from staged changes:

```sh
kamkanam generate
```

The git hook runs automatically on `git commit` and updates the message.
If a message already exists, kamkanam verifies it and rewrites it if needed.
If you want it to generate the subject, run `git commit` without `-m`.

Final format:

```
<type> : <commit message> : ai-usage <percentage>
```

The `REVIEW:` prefix appears inside the commit message only when the AI
percentage exceeds the threshold.

## TUI commit flow

To see the generated message inside the `git commit` session and confirm it:

```sh
git config --global core.editor "kamkanam editor"
```

Now `git commit` will show the message in the terminal and wait for Enter.
Type `q` to abort the commit.

Notes:

- If you pass `-m`, the editor is skipped, so the TUI will not appear.
- Disable the prompt for one commit with `KAMKANAM_TUI=0 git commit`.

## Setup

Set your Gemini API key in your shell profile:

```sh
export KAMKANAM_GEMINI_API_KEY="YOUR_KEY"
```

Make sure your install prefix is on `PATH` (for example `~/.local/bin`).

## Environment variables

- `KAMKANAM_GEMINI_API_KEY` or `GEMINI_API_KEY` (required for Gemini)
- `KAMKANAM_GEMINI_MODEL` (default: `gemini-2.5-flash`)
- `KAMKANAM_REVIEW_THRESHOLD` (default: `50`, legacy `KAMKANAM_CRUCIAL_THRESHOLD`)
- `KAMKANAM_MAX_MESSAGE_LEN` (default: `72`)
- `KAMKANAM_AI_PERCENT` (force AI percent in output, `0-100`)
- `KAMKANAM_MAX_DIFF_CHARS` (default: `12000`)
- `KAMKANAM_REQUIRE_GEMINI` (`1` to fail if Gemini is unavailable)
- `KAMKANAM_TUI` (`1` to prompt in `kamkanam editor`, `0` to auto-accept)

## Debugging

If you do not see a generated commit message:

- The `commit-msg` hook runs after your editor closes, so you will not see the
  generated text inside the editor. Check it with `git log -1` or run
  `kamkanam generate` to preview.
- If you pass `-m`, kamkanam treats that message as input and may rewrite it
  to match the diff and required format.
- Confirm you have staged changes: `git diff --cached`.
- Confirm the hook is installed and executable:
  `ls -l ~/.config/git/hooks/commit-msg`.
- Confirm the hook path: `git config --global core.hooksPath`.
- Confirm the binary is on `PATH`: `command -v kamkanam`.
- Force Gemini errors to surface: `KAMKANAM_REQUIRE_GEMINI=1 kamkanam generate`.
- Print extra debug info during commits:
  `KAMKANAM_DEBUG=1 GIT_TRACE_HOOKS=1 git commit`.

## AI percentage heuristic

kamkanam counts added lines in the staged diff and marks a line as AI-like if:

- it looks like generic AI-style comments/docstrings (e.g. "This function",
  "Args:", "Returns:", "Usage")
- it includes AI disclaimers (e.g. "as an AI")
- it is part of a repeated long-line pattern

This heuristic ignores `@generated` annotations and file paths. It is used as a
hint in the prompt and as a fallback when Gemini is unavailable.

You can override the percent via `KAMKANAM_AI_PERCENT` or `--ai-percent`.
