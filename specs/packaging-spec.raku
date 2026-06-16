use lib 'lib', 'specs/lib';
use BDD::Behave;
use WWW::Playwright::Sidecar;
use WWW::Playwright::Exception;

describe 'packaging and resource resolution', {
  context 'the sidecar script resource', {
    my $script = WWW::Playwright::Sidecar.script-path;

    it 'resolves through %?RESOURCES', {
      expect($script.basename).to.eq('sidecar.mjs');
    }

    it 'exists on disk', {
      expect($script.e).to.be-truthy;
    }
  }

  context 'missing npm dependencies', {
    it 'make start throw DependenciesMissing', {
      my $dir = $*TMPDIR.add("pw-pkg-{$*PID}-{(^999999).pick}");
      $dir.mkdir;
      $dir.add('sidecar.mjs').spurt('');

      my $sidecar = WWW::Playwright::Sidecar.new(:script-path($dir.add('sidecar.mjs').absolute));

      expect({ $sidecar.start }).to.raise-error(X::WWW::Playwright::DependenciesMissing);

      $dir.add('sidecar.mjs').unlink;
      $dir.rmdir;
    }

    it 'point the error at bin/install', {
      my $error = X::WWW::Playwright::DependenciesMissing.new(resources-dir => '/somewhere');

      expect($error.message).to.match(/'bin/install'/);
    }
  }

  context 'classifying a missing-browser error', {
    it 'recognizes a Playwright launch failure', {
      expect(is-missing-browser-error("browserType.launch: Executable doesn't exist\nnpx playwright install")).to.be-truthy;
    }

    it 'leaves unrelated messages alone', {
      expect(is-missing-browser-error('some unrelated locator timeout')).to.be-falsy;
    }
  }
};
