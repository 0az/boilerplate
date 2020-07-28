#! /usr/bin/env node
/*
 * MIT License
 *
 * Copyright (c) 2020 Andrew Zhou
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import browsersync from 'browser-sync';

import { argv, chdir, exit } from 'process';

const bs = browsersync.create();

const usage = 'Usage: serve.mjs [directory]';

if (argv.length > 3) {
  console.error('Too many arguments!');
  console.error(usage);
  exit(1);
}

if (argv.length == 3) {
  chdir(argv[2]);
}

// Browser-sync config
// http://www.browsersync.io/docs/options/

const bsServerConfig = {
  server: true,
  proxy: false,
  host: null,
  port: 3000,
  serveStatic: ['.'],
  ui: {
    port: 3001,
  },
};
const bsWatchConfig = {
  files: false,
  watchEvents: ['add', 'change'],
  watch: true,
  watchOptions: {
    ignoreInitial: true,
  },
};
const bsBrowserConfig = {
  open: false,
  browser: 'default',
  startPath: null,
  reloadOnRestart: true,
  notify: true,
  scrollThrottle: 0,
  reloadDelay: 0,
  reloadDebounce: 500,
  reloadThrottle: 0,
  injectNotification: false,
};
const bsConfig = {
  ...bsServerConfig,
  ...bsWatchConfig,
  ...bsBrowserConfig,
  plugins: [],
  logConnections: false,
  logFileChanges: true,
  logSnippet: true,
  injectChanges: true, // Try to inject CSS changes
  timestamps: true,
};

bs.init(bsConfig);
