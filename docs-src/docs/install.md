# Installing

`WWW::Playwright` drives a Node process, so it needs three things in place: Node
itself, the `playwright` npm package, and the Chromium browser binary.

## Node

Install Node 18 or newer. The transport finds `node` on `PATH`; override the path
with `PLAYWRIGHT_NODE` if needed (see [Configuration](configuration.md)).

```bash
node --version
```

## The Raku distribution

```bash
zef install WWW::Playwright
```

## The npm package and the browser binary

After the Raku distribution is installed, run `bin/install`. It installs the
pinned `playwright` npm package and the Chromium binary next to the sidecar
script.

```bash
install        # the bin/install script shipped with the distribution
```

`bin/install` runs two steps in the sidecar resources directory:

1. `npm install` to fetch the pinned `playwright` package.
2. `npx playwright install chromium` to download the browser binary.

## What happens when a step is missing

- If the npm package is not installed, starting the sidecar throws
  `X::WWW::Playwright::DependenciesMissing`, pointing back at `bin/install`.
- If the browser binary is not installed, `launch` throws
  `X::WWW::Playwright::BrowserNotInstalled`, also pointing at `bin/install`.
