import { createInterface } from 'node:readline';
import { chromium } from 'playwright';

const registry = new Map();
const counters = new Map();
const browsers = new Set();

function mint(kind, object) {
  const next = (counters.get(kind) ?? 0) + 1;

  counters.set(kind, next);

  const handle = `${kind}@${next}`;

  registry.set(handle, object);

  return handle;
}

function resolve(handle) {
  if (!registry.has(handle)) {
    const error = new Error(`unknown handle: ${handle}`);

    error.name = 'UnknownHandle';

    throw error;
  }

  return registry.get(handle);
}

function forget(handle) {
  registry.delete(handle);
}

const methods = {
  ping() {
    return 'pong';
  },

  echo(params = {}) {
    return params;
  },

  async launch({ headless = true } = {}) {
    const browser = await chromium.launch({ headless });

    browsers.add(browser);

    return mint('browser', browser);
  },

  async close({ handle } = {}) {
    const object = resolve(handle);

    await object.close();

    browsers.delete(object);
    forget(handle);

    return null;
  },

  async 'new-context'({ handle } = {}) {
    const browser = resolve(handle);

    const context = await browser.newContext();

    return mint('context', context);
  },

  async 'new-page'({ handle } = {}) {
    const context = resolve(handle);

    const page = await context.newPage();

    return mint('page', page);
  },

  async goto({ handle, url } = {}) {
    const page = resolve(handle);

    const response = await page.goto(url);

    return response ? response.status() : null;
  },

  locator({ handle, selector } = {}) {
    const root = resolve(handle);

    return mint('loc', root.locator(selector));
  },

  async click({ handle } = {}) {
    await resolve(handle).click();

    return null;
  },

  async fill({ handle, value } = {}) {
    await resolve(handle).fill(value);

    return null;
  },

  async type({ handle, text } = {}) {
    await resolve(handle).pressSequentially(text);

    return null;
  },

  async press({ handle, key } = {}) {
    await resolve(handle).press(key);

    return null;
  },

  async check({ handle } = {}) {
    await resolve(handle).check();

    return null;
  },

  async uncheck({ handle } = {}) {
    await resolve(handle).uncheck();

    return null;
  },

  async 'select-option'({ handle, value } = {}) {
    return resolve(handle).selectOption(value);
  },

  async hover({ handle } = {}) {
    await resolve(handle).hover();

    return null;
  },

  async 'text-content'({ handle } = {}) {
    return resolve(handle).textContent();
  },

  async 'inner-text'({ handle } = {}) {
    return resolve(handle).innerText();
  },

  async 'get-attribute'({ handle, name } = {}) {
    return resolve(handle).getAttribute(name);
  },

  async 'input-value'({ handle } = {}) {
    return resolve(handle).inputValue();
  },

  async count({ handle } = {}) {
    return resolve(handle).count();
  },

  async 'is-visible'({ handle } = {}) {
    return resolve(handle).isVisible();
  },

  async 'is-enabled'({ handle } = {}) {
    return resolve(handle).isEnabled();
  },

  async 'is-checked'({ handle } = {}) {
    return resolve(handle).isChecked();
  },

  async 'wait-for'({ handle, state } = {}) {
    await resolve(handle).waitFor(state ? { state } : undefined);

    return null;
  },

  async screenshot({ handle, path } = {}) {
    const page = resolve(handle);

    const buffer = await page.screenshot(path ? { path } : {});

    return Array.from(buffer);
  },

  async 'start-tracing'({ handle } = {}) {
    const context = resolve(handle);

    await context.tracing.start({ screenshots: true, snapshots: true });

    return null;
  },

  async 'stop-tracing'({ handle, path } = {}) {
    const context = resolve(handle);

    await context.tracing.stop(path ? { path } : {});

    return null;
  },
};

function send(response) {
  process.stdout.write(JSON.stringify(response) + '\n');
}

function successFor(id, result) {
  return { jsonrpc: '2.0', id, result };
}

function errorFor(id, code, message, data) {
  const error = { code, message };

  if (data !== undefined) {
    error.data = data;
  }

  return { jsonrpc: '2.0', id, error };
}

async function handle(line) {
  const trimmed = line.trim();

  if (trimmed.length === 0) {
    return;
  }

  let request;

  try {
    request = JSON.parse(trimmed);
  } catch (parseError) {
    send(errorFor(null, -32700, 'Parse error', { name: 'SyntaxError', stack: parseError.stack }));

    return;
  }

  const id = request?.id ?? null;

  if (request === null || typeof request !== 'object' || typeof request.method !== 'string') {
    send(errorFor(id, -32600, 'Invalid Request'));

    return;
  }

  const method = methods[request.method];

  if (!method) {
    process.stderr.write(`method not found: ${request.method}\n`);

    send(errorFor(id, -32601, `Method not found: ${request.method}`));

    return;
  }

  try {
    const result = await method(request.params ?? {});

    send(successFor(id, result));
  } catch (thrown) {
    const data = { name: thrown?.name ?? 'Error', stack: thrown?.stack ?? '' };

    process.stderr.write(`error in ${request.method}: ${thrown?.message ?? String(thrown)}\n`);

    send(errorFor(id, -32000, thrown?.message ?? String(thrown), data));
  }
}

async function cleanup() {
  for (const browser of browsers) {
    try {
      await browser.close();
    } catch {
      // a browser already gone is not worth crashing the shutdown over
    }
  }

  browsers.clear();
}

const reader = createInterface({ input: process.stdin });

reader.on('line', (line) => {
  handle(line);
});

reader.on('close', async () => {
  await cleanup();

  process.exit(0);
});

for (const signal of ['SIGINT', 'SIGTERM']) {
  process.on(signal, async () => {
    await cleanup();

    process.exit(0);
  });
}
