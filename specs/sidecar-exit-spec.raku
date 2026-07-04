use lib 'lib', 'specs/lib';
use BDD::Behave;
use PlaywrightSupport;
use WWW::Playwright::Sidecar;
use WWW::Playwright::Exception;

describe 'sidecar exit while a request is pending', {
  my $home;

  before-each {
    $home = $*TMPDIR.add("pw-exit-{$*PID}-{(^999999).pick}");
    $home.mkdir;
    $home.add('sidecar.mjs').spurt(trivial-sidecar-source());
    $home.add('node_modules').add('playwright').mkdir;
  }

  after-each {
    rm-rf($home);
  }

  it 'breaks a still-pending request instead of hanging', {
    my $sidecar = WWW::Playwright::Sidecar.new(:script-path($home.add('sidecar.mjs').absolute));

    $sidecar.start;

    my $call = $sidecar.call('ping');

    $sidecar.stop;

    expect({ $call.result }).to.raise-error(X::WWW::Playwright::SidecarExited);
  }
};
