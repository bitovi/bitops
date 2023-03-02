# BitOps Unit Tests

This directory contains tests for the BitOps core.
We use the built-in [`unittest`](https://docs.python.org/3/library/unittest.html) module as a framework for testing.

## Running the tests
The testing command is defined in [`tox.ini`](../../tox.ini) and can be run with `tox`:
```bash
tox -e unit
```

## VSCode Configuration
The repository contains a `.vscode/settings.json` file that configures VSCode to auto-discover the tests and run the test suite.

![VSCode Tests Suite Configuration](https://code.visualstudio.com/assets/docs/python/testing/test-results.png)

See [Python Testing in VSCode](https://code.visualstudio.com/docs/python/testing) for more information.
