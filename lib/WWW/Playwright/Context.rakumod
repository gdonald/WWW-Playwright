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

method close(--> Nil) {
  $.sidecar.call('close', %( handle => $.handle )).result;

  Nil;
}
