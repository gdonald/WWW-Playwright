use lib 'lib';
use BDD::Behave;
use WWW::Playwright;

describe 'WWW::Playwright distribution', {
  it 'loads the module', {
    expect(WWW::Playwright.^name).to.eq('WWW::Playwright');
  }

  it 'exposes a defined distribution version', {
    expect(WWW::Playwright.dist-version.defined).to.be-truthy;
  }
};
