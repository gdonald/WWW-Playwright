use lib 'lib', 'specs/lib';
use BDD::Behave;
use PlaywrightSupport;

describe 'browser, context, and page lifecycle', {
  it 'navigates to a file:// fixture and returns HTTP 200', {
    with-playwright(-> $playwright {
      my $browser = $playwright.launch;
      my $context = $browser.new-context;
      my $page    = $context.new-page;

      my $status = $page.goto(fixture-url('hello.html'));

      $page.close;
      $context.close;
      $browser.close;

      expect($status).to.be(200);
    });
  }
};
