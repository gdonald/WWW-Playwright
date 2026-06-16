use v6.d;
use JSON::Fast;
use WWW::Playwright::Exception;

unit class WWW::Playwright::Sidecar;

has Str $.node-binary;
has Str $.script-path;
has Proc::Async $!proc;
has Promise $!exited;
has Promise $!stdout-done;
has Promise $!stderr-done;
has Lock $!lock = Lock.new;
has Int $!next-id = 0;
has %!pending;
has @!stderr-lines;
has Bool $!debug;
has IO::Handle $!debug-handle;

sub find-on-path(Str $name --> Str) {
  my $path = %*ENV<PATH> // '';

  for $path.split(':').grep(*.chars) -> $dir {
    my $candidate = $dir.IO.add($name);

    return $candidate.absolute if $candidate.e && $candidate.x;
  }

  Str;
}

sub resolve-node(--> Str) {
  with %*ENV<PLAYWRIGHT_NODE> -> $override {
    return $override if $override.IO.e && $override.IO.x;

    die X::WWW::Playwright::NodeNotFound.new(binary => $override);
  }

  my $found = find-on-path('node');

  die X::WWW::Playwright::NodeNotFound.new(binary => 'node') without $found;

  $found;
}

method script-path(--> IO::Path) {
  %?RESOURCES<sidecar/sidecar.mjs>.IO;
}

submethod TWEAK() {
  $!node-binary //= resolve-node();
  $!script-path //= self.script-path.absolute;
  $!debug = ?%*ENV<PLAYWRIGHT_DEBUG>;
}

method !verify-dependencies(--> Nil) {
  my $playwright = $!script-path.IO.parent.add('node_modules').add('playwright');

  die X::WWW::Playwright::DependenciesMissing.new(
    resources-dir => $!script-path.IO.parent.absolute,
  ) unless $playwright.e;

  Nil;
}

method stderr-lines(--> List) {
  $!lock.protect({ @!stderr-lines.List });
}

method start(--> Nil) {
  self!verify-dependencies;

  $!proc = Proc::Async.new(:w, $!node-binary, $!script-path);

  $!debug-handle = $*ERR if $!debug;

  $!stdout-done = Promise.new;
  $!stderr-done = Promise.new;

  $!proc.stdout.lines.tap(-> $line { self!receive($line) }, done => { $!stdout-done.keep });
  $!proc.stderr.lines.tap(-> $line { self!receive-stderr($line) }, done => { $!stderr-done.keep });

  $!exited = $!proc.start;

  Nil;
}

method !receive(Str $line) {
  return unless $line.trim.chars;

  my %message = from-json($line);
  my $id = %message<id>;

  my $vow;
  $!lock.protect({ $vow = %!pending{$id}:delete });

  return without $vow;

  if %message<error>:exists {
    my %error = %message<error>;

    $vow.break(X::WWW::Playwright.new(
      code          => %error<code>,
      error-message => %error<message>,
      data          => %error<data> // %(),
    ));
  }
  else {
    $vow.keep(%message<result>);
  }
}

method !receive-stderr(Str $line) {
  $!lock.protect({ @!stderr-lines.push($line) });

  $!debug-handle.say("[playwright-sidecar] $line") if $!debug-handle;
}

method call(Str $method, %params = %() --> Promise) {
  my $promise = Promise.new;
  my $vow = $promise.vow;

  my $id;

  $!lock.protect({
    $id = ++$!next-id;
    %!pending{$id} = $vow;
  });

  my $request = to-json(
    %( jsonrpc => '2.0', :$id, :$method, params => %params ),
    :!pretty,
  );

  $!proc.say($request);

  $promise;
}

method stop(--> Nil) {
  return without $!proc;

  $!proc.close-stdin;

  await $!exited;
  await $!stdout-done, $!stderr-done;

  Nil;
}
