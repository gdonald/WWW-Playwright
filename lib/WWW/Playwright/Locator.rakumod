use v6.d;

use WWW::Playwright::Sidecar;

unit class WWW::Playwright::Locator;

has WWW::Playwright::Sidecar $.sidecar is required;
has Str $.handle is required;

method !invoke(Str $method, *%params) {
  $.sidecar.call($method, %( handle => $.handle, |%params )).result;
}

method locator(Str $selector --> WWW::Playwright::Locator) {
  my $child = self!invoke('locator', :$selector);

  WWW::Playwright::Locator.new(:$.sidecar, :handle($child));
}

method click(--> Nil)   { self!invoke('click');   Nil }
method check(--> Nil)   { self!invoke('check');   Nil }
method uncheck(--> Nil) { self!invoke('uncheck'); Nil }
method hover(--> Nil)   { self!invoke('hover');   Nil }

method fill(Str $value --> Nil) { self!invoke('fill', :$value); Nil }
method type(Str $text --> Nil)  { self!invoke('type', :$text);  Nil }
method press(Str $key --> Nil)  { self!invoke('press', :$key);  Nil }

method select-option(Str $value --> List) {
  self!invoke('select-option', :$value).List;
}

method text-content(--> Str)        { self!invoke('text-content') }
method inner-text(--> Str)          { self!invoke('inner-text') }
method get-attribute(Str $name)     { self!invoke('get-attribute', :$name) }
method input-value(--> Str)         { self!invoke('input-value') }
method count(--> Int)               { self!invoke('count') }
method is-visible(--> Bool)         { self!invoke('is-visible') }
method is-enabled(--> Bool)         { self!invoke('is-enabled') }
method is-checked(--> Bool)         { self!invoke('is-checked') }

method wait-for(Str :$state --> Nil) {
  self!invoke('wait-for', :$state);

  Nil;
}
