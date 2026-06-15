use lib 'lib', 'specs/lib';
use BDD::Behave;
use PlaywrightSupport;
use WWW::Playwright;

describe 'locator API', {
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

  context 'actions', {
    it 'click triggers the button handler', {
      $page.locator('#go').click;

      expect($page.locator('#result').text-content).to.eq('clicked');
    }

    it 'fill sets the input value', {
      $page.locator('#name').fill('Ada');

      expect($page.locator('#name').input-value).to.eq('Ada');
    }

    it 'type appends keystrokes to the input', {
      $page.locator('#name').fill('');
      $page.locator('#name').type('Hi');

      expect($page.locator('#name').input-value).to.eq('Hi');
    }

    it 'press dispatches a key event', {
      $page.locator('#name').press('x');

      expect($page.locator('#key-result').text-content).to.eq('x');
    }

    it 'check ticks the checkbox', {
      $page.locator('#agree').check;

      expect($page.locator('#agree').is-checked).to.be-truthy;
    }

    it 'uncheck clears the checkbox', {
      $page.locator('#agree').check;
      $page.locator('#agree').uncheck;

      expect($page.locator('#agree').is-checked).to.be-falsy;
    }

    it 'select-option returns the chosen values', {
      my @selected = $page.locator('#color').select-option('green');

      expect(@selected).to.eq(['green']);
    }

    it 'hover triggers the mouseover handler', {
      $page.locator('#hoverable').hover;

      expect($page.locator('#hover-result').text-content).to.eq('hovered');
    }
  }

  context 'queries', {
    it 'text-content reads the element text', {
      expect($page.locator('#greeting').text-content).to.eq('Hello, world');
    }

    it 'inner-text reads the rendered text', {
      expect($page.locator('#greeting').inner-text).to.eq('Hello, world');
    }

    it 'get-attribute reads an attribute', {
      expect($page.locator('#name').get-attribute('type')).to.eq('text');
    }

    it 'input-value reads the current value', {
      $page.locator('#name').fill('typed');

      expect($page.locator('#name').input-value).to.eq('typed');
    }

    it 'count returns the number of matches', {
      expect($page.locator('#color option').count).to.be(3);
    }

    it 'is-visible reports a visible element', {
      expect($page.locator('#greeting').is-visible).to.be-truthy;
    }

    it 'is-enabled reports an enabled element', {
      expect($page.locator('#name').is-enabled).to.be-truthy;
    }

    it 'is-checked reports a ticked checkbox', {
      $page.locator('#agree').check;

      expect($page.locator('#agree').is-checked).to.be-truthy;
    }
  }

  context 'auto-waiting and chaining', {
    it 'wait-for resolves once the state is reached', {
      $page.locator('#greeting').wait-for(state => 'visible');

      expect($page.locator('#greeting').is-visible).to.be-truthy;
    }

    it 'locators chain through nested selectors', {
      expect($page.locator('body').locator('#greeting').text-content).to.eq('Hello, world');
    }
  }
};
