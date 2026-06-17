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

`bin/install` runs two steps in the sidecar home directory:

1. `npm install` to fetch the pinned `playwright` package.
2. `npx playwright install chromium` to download the browser binary.

### Where the sidecar home is

The sidecar home is the directory the sidecar resolves `playwright` from at
runtime, and it depends on how the distribution is laid out:

- **Repo checkout** (running with `-Ilib`): the home is `resources/sidecar`,
  where `package.json` and `sidecar.mjs` already live side by side. `bin/install`
  installs `node_modules` there.
- **Installed from zef**: resources are stored content-addressed, so the sidecar
  script and `package.json` are not siblings. `bin/install` materializes them
  into a per-version cache directory (under `$XDG_CACHE_HOME` or `~/.cache`) and
  installs `node_modules` there. The sidecar then runs from that cache copy, so
  Node resolves `playwright` next to it.

Either way, the directory `bin/install` writes to is the same one the transport
checks at `start`, so a successful `bin/install` clears the
`DependenciesMissing` error. Run `bin/install` once after each `zef install` or
upgrade.

## What happens when a step is missing

- If the npm package is not installed, starting the sidecar throws
  `X::WWW::Playwright::DependenciesMissing`, pointing back at `bin/install`.
- If the browser binary is not installed, `launch` throws
  `X::WWW::Playwright::BrowserNotInstalled`, also pointing at `bin/install`.
