# WWW::Playwright

A Raku driver for [Playwright](https://playwright.dev). Raku spawns a long-lived
Node sidecar that imports the official `playwright` package, and talks to it over
newline-delimited JSON-RPC on stdio. Raku owns the API surface and lifecycle.
Node owns the browser.

## Install

```bash
zef install WWW::Playwright
install              # the bin/install script: npm install + playwright install chromium
```

`bin/install` fetches the pinned `playwright` npm package and the Chromium binary
next to the sidecar script. Node 18 or newer must be on `PATH` (or pointed at by
`PLAYWRIGHT_NODE`).

## Usage

```raku
use WWW::Playwright;

my $playwright = WWW::Playwright.start;
my $browser    = $playwright.launch;          # headless Chromium
my $context    = $browser.new-context;
my $page       = $context.new-page;

$page.goto('file:///path/to/page.html');

$page.locator('#name').fill('Ada');
$page.locator('#go').click;

say $page.locator('#result').text-content;

$page.close;
$context.close;
$browser.close;
$playwright.stop;
```

## API

- `WWW::Playwright` - `start`, `launch(:headless)`, `ping`, `stop`.
- `Browser` - `new-context`, `close`.
- `Context` - `new-page`, `start-tracing`, `stop-tracing(:path)`, `close`.
- `Page` - `goto`, `locator`, `screenshot(:path)`, `close`.
- `Locator` - actions (`click`, `fill`, `type`, `press`, `check`, `uncheck`,
  `select-option`, `hover`), queries (`text-content`, `inner-text`,
  `get-attribute`, `input-value`, `count`, `is-visible`, `is-enabled`,
  `is-checked`), `wait-for(:state)`, and `locator` chaining.

## Environment

- `PLAYWRIGHT_NODE` - path to the Node binary (defaults to `node` on `PATH`).
- `PLAYWRIGHT_DEBUG` - when set, streams sidecar stderr to the Raku process stderr.

## Documentation

Full docs are built from `docs-src` with mkdocs.

## License

Artistic-2.0
