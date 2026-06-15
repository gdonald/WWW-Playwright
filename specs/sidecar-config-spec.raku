use lib 'lib', 'specs/lib';
use BDD::Behave;
use PlaywrightSupport;
use WWW::Playwright::Sidecar;
use WWW::Playwright::Exception;

describe 'WWW::Playwright::Sidecar configuration', {
  context 'node binary resolution', {
    it 'lets PLAYWRIGHT_NODE override the resolved binary', {
      my $real-node = WWW::Playwright::Sidecar.new.node-binary;

      with-env(%( PLAYWRIGHT_NODE => $real-node ), {
        expect(WWW::Playwright::Sidecar.new.node-binary).to.eq($real-node);
      });
    }

    it 'throws NodeNotFound when PLAYWRIGHT_NODE points at nothing', {
      with-env(%( PLAYWRIGHT_NODE => '/no/such/node-binary' ), {
        expect({ WWW::Playwright::Sidecar.new }).to.raise-error(X::WWW::Playwright::NodeNotFound);
      });
    }

    it 'throws NodeNotFound when node is absent from PATH', {
      with-env(%( PLAYWRIGHT_NODE => Nil, PATH => '' ), {
        expect({ WWW::Playwright::Sidecar.new }).to.raise-error(X::WWW::Playwright::NodeNotFound);
      });
    }
  }

  context 'sidecar stderr', {
    it 'is captured', {
      my $sidecar = WWW::Playwright::Sidecar.new;
      $sidecar.start;

      my $call = $sidecar.call('no-such-method');

      $sidecar.stop;

      try { $call.result }

      expect($sidecar.stderr-lines.elems).to.be-greater-than(0);
    }

    it 'streams to the debug log when PLAYWRIGHT_DEBUG is set', {
      my $tmp = $*TMPDIR.add("pw-debug-{$*PID}-{(^999999).pick}");

      with-env(%( PLAYWRIGHT_DEBUG => '1' ), {
        my $*ERR = $tmp.open(:w);

        my $sidecar = WWW::Playwright::Sidecar.new;
        $sidecar.start;

        my $call = $sidecar.call('no-such-method');

        $sidecar.stop;

        try { $call.result }

        $*ERR.close;
      });

      my $logged = $tmp.slurp;
      $tmp.unlink;

      expect($logged).to.match(/'playwright-sidecar'/);
    }
  }
};
