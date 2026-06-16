# Page

A `WWW::Playwright::Page` is a single tab. Get one from
[`Context.new-page`](context.md).

## `goto(Str $url --> Int)`

Navigates to a URL and returns the HTTP status of the navigation response.

```raku
my $status = $page.goto('file:///path/to/hello.html');   # 200
```

## `locator(Str $selector --> Locator)`

Returns a [`Locator`](locator.md) for the selector. This is the entry point to
every action and query.

```raku
my $heading = $page.locator('#greeting');
```

## `screenshot(Str :$path --> Buf)`

Captures the page as a PNG and returns the bytes. With `:path`, also writes the
image to that path.

```raku
my $bytes = $page.screenshot(path => '/tmp/page.png');
```

See [Diagnostics](../diagnostics.md).

## `close(--> Nil)`

Closes the page.

```raku
$page.close;
```
