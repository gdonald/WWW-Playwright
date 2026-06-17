use lib 'lib', 'specs/lib';
use BDD::Behave;
use PlaywrightSupport;
use WWW::Playwright::Sidecar;

describe 'installed sidecar dependency resolution', {
  my $suffix;
  my $store;
  my $package;
  my $lock;
  my $cache;
  my $home;

  before-each {
    $suffix = "{$*PID}-{(^999999).pick}";

    $store = $*TMPDIR.add("pw-store-$suffix");
    $store.mkdir;
    $store.add('sidecar.mjs').spurt(trivial-sidecar-source());

    $package = $*TMPDIR.add("pw-pkg-$suffix.json");
    $package.spurt('{"name":"www-playwright-sidecar"}');

    $lock = $*TMPDIR.add("pw-lock-$suffix.json");
    $lock.spurt('{}');

    $cache = $*TMPDIR.add("pw-cache-$suffix");

    $home = WWW::Playwright::Sidecar::resolve-home($store.add('sidecar.mjs'), $package, $lock, $cache);
  }

  after-each {
    rm-rf($store);
    rm-rf($cache);
    $package.unlink if $package.e;
    $lock.unlink if $lock.e;
  }

  it 'reads a sidecar with no sibling package.json as an installed layout', {
    expect(WWW::Playwright::Sidecar::is-checkout-layout($store.add('sidecar.mjs'))).to.be-falsy;
  }

  it 'materializes the sidecar script and package.json into the resolved home', {
    aggregate-failures {
      expect($home.add('sidecar.mjs').e).to.be-truthy;
      expect($home.add('package.json').e).to.be-truthy;
    }
  }

  it 'finds node_modules in the resolved home', {
    $home.add('node_modules').add('playwright').mkdir;

    expect(WWW::Playwright::Sidecar::has-playwright($home)).to.be-truthy;
  }

  it 'does not raise the missing-dependencies error against an installed layout', {
    $home.add('node_modules').add('playwright').mkdir;

    my $sidecar = WWW::Playwright::Sidecar.new(:script-path($home.add('sidecar.mjs').absolute));

    expect({ $sidecar.start; $sidecar.stop }).to.not.raise-error;
  }
};

describe 'checkout sidecar dependency resolution', {
  it 'reads a sidecar next to package.json as a checkout layout', {
    my $suffix = "{$*PID}-{(^999999).pick}";

    my $checkout = $*TMPDIR.add("pw-checkout-$suffix");
    $checkout.mkdir;
    $checkout.add('sidecar.mjs').spurt(trivial-sidecar-source());
    $checkout.add('package.json').spurt('{}');

    LEAVE rm-rf($checkout);

    expect(WWW::Playwright::Sidecar::is-checkout-layout($checkout.add('sidecar.mjs'))).to.be-truthy;
  }
};
