# Context

A `WWW::Playwright::Context` is an isolated browser session. Get one from
[`Browser.new-context`](browser.md).

## `new-page(--> Page)`

Opens a new page in the context and returns a [`Page`](page.md).

```raku
my $page = $context.new-page;
```

## `start-tracing(--> Nil)`

Starts recording a trace (screenshots and DOM snapshots) for the context.

```raku
$context.start-tracing;
```

## `stop-tracing(Str :$path --> Nil)`

Stops tracing. With `:path`, writes the trace zip to that path.

```raku
$context.stop-tracing(path => '/tmp/trace.zip');
```

See [Diagnostics](../diagnostics.md) for the full tracing workflow.

## `close(--> Nil)`

Closes the context and its pages.

```raku
$context.close;
```
