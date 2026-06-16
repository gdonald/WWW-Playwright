use lib 'lib', 'specs/lib';
use BDD::Behave;
use PlaywrightSupport;
use WWW::Playwright;

describe 'diagnostics', {
  my $playwright;
  my $browser;

  before-all {
    $playwright = WWW::Playwright.start;
    $browser    = $playwright.launch;
  }

  after-all {
    $browser.close;
    $playwright.stop;
  }

  context 'screenshot to a path', {
    my $context;
    my $page;
    my $path;
    my $bytes;

    before-each {
      $context = $browser.new-context;
      $page    = $context.new-page;

      $page.goto(fixture-url('hello.html'));

      $path  = $*TMPDIR.add("pw-shot-{$*PID}-{(^999999).pick}.png");
      $bytes = $page.screenshot(path => $path.absolute);
    }

    after-each {
      $path.unlink if $path.e;
      $context.close;
    }

    it 'writes a non-empty file at the given path', {
      expect($path.s).to.be-greater-than(0);
    }

    it 'returns the PNG bytes', {
      expect($bytes[0..3].list).to.eq((137, 80, 78, 71));
    }
  }

  context 'screenshot without a path', {
    my $context;
    my $page;

    before-each {
      $context = $browser.new-context;
      $page    = $context.new-page;

      $page.goto(fixture-url('hello.html'));
    }

    after-each {
      $context.close;
    }

    it 'returns the bytes only', {
      expect($page.screenshot.elems).to.be-greater-than(0);
    }
  }

  context 'tracing', {
    my $context;
    my $path;

    before-each {
      $path = $*TMPDIR.add("pw-trace-{$*PID}-{(^999999).pick}.zip");

      $context = $browser.new-context;
      $context.start-tracing;

      my $page = $context.new-page;
      $page.goto(fixture-url('hello.html'));
      $page.locator('#go').click;

      $context.stop-tracing(path => $path.absolute);
    }

    after-each {
      $path.unlink if $path.e;
      $context.close;
    }

    it 'writes a non-empty trace zip', {
      expect($path.s).to.be-greater-than(0);
    }
  }
};
