# Fossil
Fossil is a server archive manager for the Pterodactyl Game Panel! Backups can be managed easily with Fossil's simple command system.

## Installation
This package is not officially distributed yet so it needs to be build from source. [Crystal](https://crystal-lang.org/install/) `v1.3.2` or above is required.

1. Clone this repository (`git clone https://github.com/PteroPackages/Fossil.git`)
2. Build the package (`shards build --production`)
3. Run it! (`fossil` or `./fossil`)

## Usage
Fossil uses `/etc/fossil.conf` as the configuration file path and `/var/fossil` for archives, logs and caching. Make sure that these paths exists and that fossil has the necessary permissions to read and write to those paths (or run the `setup.sh` file to do this for you). Apart from this, the `help` command provides information on how to use Fossil.

## Development
Make sure to run the `setup.sh` file for development. When building binaries/executables, always use `shards build --production`, this will build everything that is necessary with the resulting file being in the `/bin` folder.

## Contributing
1. Fork it (<https://github.com/PteroPackages/Fossil/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors
- [Devonte](https://github.com/devnote-dev) - creator and maintainer

This repository is managed under the MIT license.

© 2022-present PteroPackages
