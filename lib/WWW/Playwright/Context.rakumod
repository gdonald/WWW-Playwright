use v6.d;

use WWW::Playwright::Sidecar;
use WWW::Playwright::Page;

unit class WWW::Playwright::Context;

has WWW::Playwright::Sidecar $.sidecar is required;
has Str $.handle is required;

method new-page(--> WWW::Playwright::Page) {
  my $page = $.sidecar.call('new-page', %( handle => $.handle )).result;

  WWW::Playwright::Page.new(:$.sidecar, :handle($page));
}

method start-tracing(--> Nil) {
  $.sidecar.call('start-tracing', %( handle => $.handle )).result;

  Nil;
}

method stop-tracing(Str :$path --> Nil) {
  my %params = handle => $.handle;
  %params<path> = $path if $path.defined;

  $.sidecar.call('stop-tracing', %params).result;

  Nil;
}

method close(--> Nil) {
  $.sidecar.call('close', %( handle => $.handle )).result;

  Nil;
}
