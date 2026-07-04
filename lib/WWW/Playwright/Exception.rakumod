use v6.d;

unit module WWW::Playwright::Exception;

class X::WWW::Playwright is Exception {
  has Int $.code;
  has Str $.error-message;
  has %.data;

  method message(--> Str) {
    my $name = %.data<name> // 'Error';

    "Playwright $name ($.code): $.error-message";
  }
}

class X::WWW::Playwright::NodeNotFound is Exception {
  has Str $.binary;

  method message(--> Str) {
    "Node binary '$.binary' not found. Install Node, or set PLAYWRIGHT_NODE to its path.";
  }
}

class X::WWW::Playwright::DependenciesMissing is Exception {
  has Str $.resources-dir;

  method message(--> Str) {
    "Sidecar npm dependencies are missing under $.resources-dir. Run bin/www-playwright-setup to install them.";
  }
}

class X::WWW::Playwright::BrowserNotInstalled is Exception {
  has Str $.detail;

  method message(--> Str) {
    "The Chromium browser binary is not installed. Run bin/www-playwright-setup to install it."
      ~ ($.detail ?? "\nPlaywright reported: $.detail" !! '');
  }
}

class X::WWW::Playwright::SidecarExited is Exception {
  has Int $.exit-code;

  method message(--> Str) {
    "The Playwright sidecar exited"
      ~ ($.exit-code.defined ?? " with status $.exit-code" !! '')
      ~ " before answering the request.";
  }
}

sub is-missing-browser-error(Str $message --> Bool) is export {
  so $message.contains("Executable doesn't exist")
    || $message.contains('playwright install')
    || $message.contains('browserType.launch');
}
