use lib 'lib', 'specs/lib';
use BDD::Behave;
use PlaywrightSupport;
use WWW::Playwright;

describe 'page URL and title queries', {
  my $playwright;
  my $browser;
  my $context;
  my $page;

  before-all {
    $playwright = WWW::Playwright.start;
    $browser    = $playwright.launch;
  }

  after-all {
    $browser.close;
    $playwright.stop;
  }

  before-each {
    $context = $browser.new-context;
    $page    = $context.new-page;

    $page.goto(fixture-url('hello.html'));
  }

  after-each {
    $context.close;
  }

  it 'url returns the current page URL', {
    expect($page.url.ends-with('specs/fixtures/hello.html')).to.be-truthy;
  }

  it 'title returns the document title', {
    expect($page.title).to.eq('Hello');
  }
};
