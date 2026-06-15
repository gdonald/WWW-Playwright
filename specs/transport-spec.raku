use lib 'lib', 'specs/lib';
use BDD::Behave;
use PlaywrightSupport;
use WWW::Playwright::Exception;

describe 'WWW::Playwright::Sidecar transport', {
  context 'concurrent in-flight calls', {
    it 'correlates each response to its own id', {
      with-sidecar(-> $sidecar {
        my @results = await (^20).map(-> $n { $sidecar.call('echo', %( value => $n )) });

        expect(@results.map(*<value>).Array).to.eq((^20).Array);
      });
    }
  }

  context 'a sidecar error', {
    it 'surfaces as X::WWW::Playwright', {
      with-sidecar(-> $sidecar {
        expect({ $sidecar.call('no-such-method').result }).to.raise-error(X::WWW::Playwright);
      });
    }
  }
};
