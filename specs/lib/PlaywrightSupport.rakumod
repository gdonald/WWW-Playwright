use WWW::Playwright;
use WWW::Playwright::Sidecar;

unit module PlaywrightSupport;

sub fixture-url(Str $name --> Str) is export {
  'file://' ~ 'specs/fixtures'.IO.add($name).absolute;
}

sub with-playwright(&block) is export {
  my $playwright = WWW::Playwright.start;

  LEAVE $playwright.stop;

  block($playwright);
}

sub with-page($browser, &block, Str :$fixture = 'hello.html') is export {
  my $context = $browser.new-context;
  my $page    = $context.new-page;

  $page.goto(fixture-url($fixture));

  LEAVE $context.close;

  block($page);
}

sub merged-env(%overrides --> Hash) {
  my %snapshot = %*ENV;

  for %overrides.kv -> $key, $value {
    $value.defined ?? (%snapshot{$key} = $value) !! (%snapshot{$key}:delete);
  }

  %snapshot;
}

sub apply-env(%env, &block) {
  my %*ENV = %env;

  block();
}

sub with-env(%overrides, &block) is export {
  apply-env(merged-env(%overrides), &block);
}

sub with-sidecar(&block) is export {
  my $sidecar = WWW::Playwright::Sidecar.new;

  $sidecar.start;

  LEAVE $sidecar.stop;

  block($sidecar);
}

sub sidecar-script(--> IO::Path) is export {
  'resources/sidecar/sidecar.mjs'.IO;
}

sub node-binary(--> Str) is export {
  %*ENV<PLAYWRIGHT_NODE> // 'node';
}

sub run-sidecar-request(Str $line --> Str) is export {
  my $proc = Proc::Async.new(:w, node-binary(), sidecar-script.Str);

  my @lines;
  my $stdout-done = Promise.new;
  $proc.stdout.lines.tap({ @lines.push($_) }, done => { $stdout-done.keep });

  my $started = $proc.start;

  $proc.say($line);
  $proc.close-stdin;

  await $started;
  await $stdout-done;

  @lines.head // '';
}