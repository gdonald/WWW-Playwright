use v6.d;

use WWW::Playwright::Sidecar;
use WWW::Playwright::Context;

unit class WWW::Playwright::Browser;

has WWW::Playwright::Sidecar $.sidecar is required;
has Str $.handle is required;

method new-context(--> WWW::Playwright::Context) {
  my $context = $.sidecar.call('new-context', %( handle => $.handle )).result;

  WWW::Playwright::Context.new(:$.sidecar, :handle($context));
}

method close(--> Nil) {
  $.sidecar.call('close', %( handle => $.handle )).result;

  Nil;
}
