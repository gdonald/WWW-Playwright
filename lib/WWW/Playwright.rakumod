use v6.d;

unit class WWW::Playwright;

use WWW::Playwright::Sidecar;
use WWW::Playwright::Browser;
use WWW::Playwright::Exception;

has WWW::Playwright::Sidecar $.sidecar is required;

method start(--> WWW::Playwright) {
  my $sidecar = WWW::Playwright::Sidecar.new;

  $sidecar.start;

  self.bless(:$sidecar);
}

method ping(--> Str) {
  $.sidecar.call('ping').result;
}

method launch(Bool :$headless = True --> WWW::Playwright::Browser) {
  my $handle = $.sidecar.call('launch', %(:$headless)).result;

  WWW::Playwright::Browser.new(:sidecar($.sidecar), :$handle);
}

method stop(--> Nil) {
  $.sidecar.stop;
}

method dist-version() {
  $?DISTRIBUTION.meta<version> // $?DISTRIBUTION.meta<ver>;
}
