# Changelog

## Unreleased

### Added

- `Locator.set-input-files(*@paths)` chooses files for a file input. Relative paths resolve against the current directory.
- `Page.accept-dialogs` accepts every `alert`, `confirm`, and `prompt` dialog the page opens from then on. Without it, Playwright dismisses them, so a `confirm` returns false.

## v0.9.1 - 2026-07-10

### Added

- `Browser.new-context` named options that emulate a device or environment across every page in the context: `viewport`, `user-agent`, `device-scale-factor`, `is-mobile`, `has-touch`, `reduced-motion`, `color-scheme`, and `locale`. Only the options you pass are sent; the rest keep Playwright's defaults.
- `X::WWW::Playwright::SidecarExited` exception. When the sidecar process exits before answering, every in-flight call is broken with this error instead of hanging.

### Changed

- Renamed the setup script from `bin/install` to `bin/www-playwright-setup`, and updated the missing-dependency and missing-browser error messages to point at it.

## v0.9.0 - 2026-06-24

### Added

- Node sidecar (`resources/sidecar/sidecar.mjs`) that imports the official `playwright` package and speaks newline-delimited JSON-RPC 2.0 over stdio, with a handle registry minting `kind@N` ids for live objects.
- `ping` transport verb returning `"pong"`, plus `launch`, `close`, and process-exit cleanup that closes the browser.
- `WWW::Playwright::Sidecar` transport: spawns the sidecar with `Proc::Async`, correlates responses by `id` through a pending-promise map, and supports concurrent in-flight calls.
- Node binary resolution from `PATH`, overridable by `PLAYWRIGHT_NODE`, with a clear error when absent.
- `X::WWW::Playwright` typed exceptions built from the JSON-RPC `error` object and rethrown on the awaiting side.
- Sidecar stderr capture into an optional debug log gated by `PLAYWRIGHT_DEBUG`.
- Browser, context, and page lifecycle: `launch(:headless)`, `Browser.new-context`, `Context.new-page`, `Page.goto`, and `close` at each level.
- Locator-first API: `Page.locator($selector)` returning a `Locator`, with chaining via `Locator.locator`.
- Locator actions: `click`, `fill`, `type`, `press`, `check`, `uncheck`, `select-option`, `hover`.
- Locator queries: `text-content`, `inner-text`, `get-attribute`, `input-value`, `count`, `is-visible`, `is-enabled`, `is-checked`.
- `wait-for(:state)` exposing Playwright auto-waiting.
- `Page.url` and `Page.title` returning the current URL and document title.
- Diagnostics: `Page.screenshot(:path)`, and `Context.start-tracing` / `stop-tracing(:path)` wrapping Playwright tracing.
- Install tooling: `bin/install` running `npm install` and `npx playwright install chromium`, with the sidecar script and `package.json` shipped as META6 `resources` resolved at runtime via `%?RESOURCES`.
- Sidecar dependency resolution that installs npm deps into the directory the sidecar resolves `playwright` from at runtime, working from both a repo checkout and a zef-installed dist.
- mkdocs documentation under `docs-src`: architecture, wire contract, getting started, action and query references, diagnostics, install, API reference, and troubleshooting pages.
