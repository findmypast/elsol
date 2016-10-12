Elsol
=====

Elsol is a Solr library for Elixir.

## Getting Started
This project requires having Elixir installed.

You can install Elixir from OS X via Homebrew with:

```bash
brew install elixir
```

Otherwise, you can 
[follow the installation instructions on elixir-lang.org](http://elixir-lang.org/install.html)

### Convenience Scripts

The following scripts provide basic shortcuts to `mix` commands to make building, developing, 
and testing easy and extensible.

To install all dependencies:

```bash
./scripts/install
```

To run tests:
```bash
./scripts/test
```

To interact with the code from a shell:

```bash
./scripts/console
```

### Tests

Elsol uses [ESpec](https://github.com/antonmi/espec) for tests. 
ESpec is a framework very much like RSpec, and seems to be thoroughly 
tested and relatively mature.