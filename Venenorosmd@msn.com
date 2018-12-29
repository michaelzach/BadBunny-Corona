# Use new container infrastructure to enable caching
sudo: false

# Choose a lightweight base image; we provide our own build tools.
language: c

# GHC depends on GMP. You can add other dependencies here as well.
addons:
  apt:
    packages:
    - libgmp-dev

# The different configurations we want to test. You could also do things like
# change flags or use --stack-yaml to point to a different file.
env:
- ARGS="--resolver nightly-2018-07-04"

before_install:
# Download and unpack the stack executable
- mkdir -p ~/.local/bin
- export PATH=$HOME/.local/bin:$PATH
- travis_retry curl -L https://www.stackage.org/stack/linux-x86_64 | tar xz --wildcards --strip-components=1 -C ~/.local/bin '*/stack'

# This line does all of the work: installs GHC if necessary, build the library,
# executables, and test suites, and runs the test suites. --no-terminal works
# around some quirks in Travis's terminal implementation.
script: stack $ARGS --no-terminal --install-ghc test --fast

# Caching so the next build will be fast too.
cache:
  directories:
  - $HOME/.stack
