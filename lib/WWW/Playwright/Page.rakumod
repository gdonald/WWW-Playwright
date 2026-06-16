use v6.d;

use WWW::Playwright::Sidecar;
use WWW::Playwright::Locator;

unit class WWW::Playwright::Page;

has WWW::Playwright::Sidecar $.sidecar is required;
has Str $.handle is required;

method goto(Str $url --> Int) {
  $.sidecar.call('goto', %( handle => $.handle, :$url )).result;
}

method locator(Str $selector --> WWW::Playwright::Locator) {
  my $handle = $.sidecar.call('locator', %( handle => $.handle, :$selector )).result;

  WWW::Playwright::Locator.new(:$.sidecar, :$handle);
}

method screenshot(Str :$path --> Buf) {
  my %params = handle => $.handle;
  %params<path> = $path if $path.defined;

  my @bytes = $.sidecar.call('screenshot', %params).result.list;

  Buf.new(@bytes);
}

method close(--> Nil) {
  $.sidecar.call('close', %( handle => $.handle )).result;

  Nil;
}
