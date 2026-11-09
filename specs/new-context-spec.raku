use BDD::Behave;
use PlaywrightSupport;
use WWW::Playwright;

sub responsive-page($context) {
  my $page = $context.new-page;

  $page.goto(fixture-url('responsive.html'));

  $page;
}

describe 'Browser.new-context options', {
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

  context 'with no options', {
    it 'uses a desktop-width viewport', {
      my $context = $browser.new-context;

      LEAVE $context.close;

      expect(responsive-page($context).locator('#wide').is-visible).to.be-truthy;
    }
  }

  context 'with a narrow viewport', {
    it 'applies the viewport so the narrow layout shows', {
      my $context = $browser.new-context(viewport => { width => 400, height => 800 });

      LEAVE $context.close;

      expect(responsive-page($context).locator('#narrow').is-visible).to.be-truthy;
    }

    it 'hides the wide layout at the narrow viewport', {
      my $context = $browser.new-context(viewport => { width => 400, height => 800 });

      LEAVE $context.close;

      expect(responsive-page($context).locator('#wide').is-visible).to.be-falsy;
    }
  }

  context 'with a dark color scheme', {
    it 'applies the color scheme so the dark layout shows', {
      my $context = $browser.new-context(color-scheme => 'dark');

      LEAVE $context.close;

      expect(responsive-page($context).locator('#dark').is-visible).to.be-truthy;
    }
  }
}
