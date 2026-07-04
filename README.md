# WWW::Playwright

A Raku driver for [Playwright](https://playwright.dev). Raku spawns a long-lived
Node sidecar that imports the official `playwright` package, and talks to it over
newline-delimited JSON-RPC on stdio. Raku owns the API surface and lifecycle.
Node owns the browser.

## Install

```bash
zef install WWW::Playwright
www-playwright-setup    # npm install + playwright install chromium
```

`bin/www-playwright-setup` fetches the pinned `playwright` npm package and the Chromium binary
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

## Mobile emulation with tracing

```raku
use WWW::Playwright;

my $playwright = WWW::Playwright.start;
my $browser    = $playwright.launch;

my $context = $browser.new-context(
    viewport   => { width => 390, height => 844 },
    user-agent => 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)',
    is-mobile  => True,
    has-touch  => True,
);

$context.start-tracing;

my $page = $context.new-page;
$page.goto('https://example.com');

$page.locator('nav').locator('a').click;      # locator chaining

$context.stop-tracing(path => 'trace.zip');

$context.close;
$browser.close;
$playwright.stop;
```

The full method reference lives in the docs site linked below.

## Environment

- `PLAYWRIGHT_NODE` - path to the Node binary (defaults to `node` on `PATH`).
- `PLAYWRIGHT_DEBUG` - when set, streams sidecar stderr to the Raku process stderr.

## Documentation

Full docs are available at [gdonald.github.io/WWW-Playwright](https://gdonald.github.io/WWW-Playwright/).

## License

[Artistic-2.0](https://github.com/gdonald/WWW-Playwright/blob/main/LICENSE)
