use lib 'lib', 'specs/lib';
use BDD::Behave;
use PlaywrightSupport;
use WWW::Playwright;

describe 'page dialogs', {
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

  it 'dismisses a confirm dialog by default', {
    $page.locator('#ask').click;

    expect($page.locator('#ask-result').text-content).to.eq('dismissed');
  }

  it 'accepts a confirm dialog after accept-dialogs', {
    $page.accept-dialogs;
    $page.locator('#ask').click;

    expect($page.locator('#ask-result').text-content).to.eq('accepted');
  }
};
