use v6.d;

use WWW::Playwright::Sidecar;
use WWW::Playwright::Context;

unit class WWW::Playwright::Browser;

has WWW::Playwright::Sidecar $.sidecar is required;
has Str $.handle is required;

method new-context(
       :$viewport,
  Str  :$user-agent,
       :$device-scale-factor,
  Bool :$is-mobile,
  Bool :$has-touch,
  Str  :$reduced-motion,
  Str  :$color-scheme,
  Str  :$locale,
  --> WWW::Playwright::Context
) {
  my %options;

  %options<viewport>          = $viewport            with $viewport;
  %options<userAgent>         = $user-agent          with $user-agent;
  %options<deviceScaleFactor> = $device-scale-factor with $device-scale-factor;
  %options<isMobile>          = $is-mobile           with $is-mobile;
  %options<hasTouch>          = $has-touch           with $has-touch;
  %options<reducedMotion>     = $reduced-motion      with $reduced-motion;
  %options<colorScheme>       = $color-scheme        with $color-scheme;
  %options<locale>            = $locale              with $locale;

  my $context = $.sidecar.call('new-context', %( handle => $.handle, options => %options )).result;

  WWW::Playwright::Context.new(:$.sidecar, :handle($context));
}

method close(--> Nil) {
  $.sidecar.call('close', %( handle => $.handle )).result;

  Nil;
}
