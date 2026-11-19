# Configuration

## Where things live

| Path | Contents |
| --- | --- |
| `~/.config/js-term/config.json` | Settings (this page) |
| `~/.config/js-term/startup/` | `*.js` / `*.mjs` / `*.cjs` files run at startup, in name order |
| `~/.local/share/js-term/history.jsonl` | Input and output history, grouped by session |
| `~/.local/share/js-term/bookmarks.json` | Directory bookmarks from `%bookmark` |
| `~/.local/share/js-term/store/` | Variables saved with `%store` |

`XDG_CONFIG_HOME` and `XDG_DATA_HOME` are respected.

## config.json

Every setting is optional. This example shows each one with its default (`//` comments and trailing commas are allowed):

```jsonc
{
  "theme": "pitch",           // the only theme for now
  "layout": "rule",           // rule (input between two rules) · block (full-width input bar) · box (rounded box)
  "typescript": "auto",       // auto (when a cell isn't JavaScript) · always · off
  "editingMode": "emacs",     // emacs · vi
  "automagic": true,          // run magics without the % prefix (cd .., pwd, ls)
  "interactivity": "last_expr", // last_expr · all · none · last_expr_or_assign
  "precision": "",            // decimals for printed numbers, e.g. "3" ("" = as JavaScript prints them)
  "autoreload": 0,            // 0 off · 1 only %aimport-ed files · 2 every CommonJS file you require
  "storeAutorestore": false,  // restore %store variables at startup
  "xmode": "context",         // minimal · plain · context · verbose
  "depth": 4,                 // how deep results are printed
  "autoImport": true,         // built-in modules (fs, path, os…) as globals, loaded on first use
  "historyLogOutput": true,   // save a short text form of each result in the history
  "execLines": [],            // code to run at startup, e.g. ["const _ = require('lodash')"]
  "execFiles": [],            // files to run at startup (like %run)
  "aliases": {}               // shell aliases, e.g. {"gs": "git status", "serve": "npx http-server %s"}
}
```

Unknown or invalid keys are reported as a warning when :js starts; they never stop it from starting.

### Changing settings in a session

```js
%config                 // every setting and its value
%config xmode           // show one
%config xmode=verbose   // change it for this session
%layout box             // shortcuts: %theme, %layout, %editmode, %xmode, %depth, %precision, %automagic, %autoreload
```

## Themes

One palette, **pitch**, shared by the input bar, the cell chrome, syntax highlighting and printed values: cool blue/violet hues on a pitch-black terminal, the same palette as :py, :sh, :http and :docs, with :js's own red accent. Backgrounds stay transparent, so the terminal's own black shows through.

:js uses 24-bit color when the terminal supports it and falls back to the nearest 256 colors otherwise. `NO_COLOR` turns colors off.

## Profiles

`:js --profile work` keeps a separate configuration, startup directory and history under `~/.config/js-term/profiles/work/` and `~/.local/share/js-term/profiles/work/`.

## Startup files

Files in the startup directory run before the first prompt, like `%run`: their top-level variables and functions are available in your session. Use them for helpers you always want:

```js
// ~/.config/js-term/startup/10-helpers.js
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const json = (value) => console.log(JSON.stringify(value, null, 2));
```

Errors in startup code are reported and skipped. `--no-startup` skips startup files and `execLines`.

## Command-line options

| Option | |
| --- | --- |
| `:js file.js [args…]` | Run a file and exit (`-i` to stay interactive afterwards) |
| `-e`, `--eval CODE` | Run code and exit |
| `-p`, `--print CODE` | Run code, print the result and exit |
| `-` | Read code from stdin (also when stdin isn't a terminal) |
| `-i`, `--interactive` | Stay interactive after `-e`, `-p` or a file |
| `--profile NAME` | Use a named profile |
| `--theme NAME` | Color theme for this session |
| `--layout NAME` | `rule` (default), `block` or `box` |
| `--vi` | vi key bindings |
| `--no-startup` | Skip startup files and `execLines` |
| `--no-history` | Don't read or write the history file |
| `-v`, `--version` · `-h`, `--help` | |
