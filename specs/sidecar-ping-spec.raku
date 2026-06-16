use lib 'lib', 'specs/lib';
use BDD::Behave;
use JSON::Fast;
use PlaywrightSupport;

describe 'sidecar ping over stdio', {
  my %response;

  before-all {
    my $request = to-json(%( jsonrpc => '2.0', id => 1, method => 'ping', params => {} ), :!pretty);

    %response = from-json(run-sidecar-request($request));
  }

  it 'uses JSON-RPC 2.0', {
    expect(%response<jsonrpc>).to.eq('2.0');
  }

  it 'echoes the request id', {
    expect(%response<id>).to.be(1);
  }

  it 'returns pong', {
    expect(%response<result>).to.eq('pong');
  }
};
