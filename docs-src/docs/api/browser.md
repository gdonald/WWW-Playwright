# Browser

A `WWW::Playwright::Browser` wraps a launched Chromium instance. Get one from
`WWW::Playwright.launch`.

## `new-context(--> Context)`

Creates an isolated browser context and returns a
[`Context`](context.md). Each context has its own cookies, storage, and pages,
which makes it the right boundary for one test.

```raku
my $context = $browser.new-context;
```

## `close(--> Nil)`

Closes the browser and every context and page under it.

```raku
$browser.close;
```
