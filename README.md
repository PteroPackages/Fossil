# Fossil
Fossil is an archive manager for the Pterodactyl game panel, able to archive user accounts, servers, nodes, and more!

## Installation
This package is not officially distributed yet so it needs to be build from source. [Crystal](https://crystal-lang.org/install/) v1.3.2 or above is required.

1. Clone this repository (`git clone https://github.com/PteroPackages/Fossil.git`)
2. Build the package (`shards build --production`)
3. Run it! (`fossil` or `./fossil`)

## Usage
Make sure to set the `FOSSIL_PATH` environment variable before doing anything. This is where the config file and error logs directory will be created, it should not be modified unless you know what you're doing.

The help command provides most of the information needed to use Fossil. Note that a lot of commands are not implemented yet including the `config set` command. To update the config, go to the `config.yml` file and edit it manually.

## Development
- [ ] Complete config subcommands
- [ ] Complete create subcommands
- [ ] Finalise testing on delete command
- [ ] Implement a zip manager
- [ ] Implement compare and prune command argument parsers

## Contributing
1. Fork it (<https://github.com/PteroPackages/Fossil/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors
- [Devonte](https://github.com/devnote-dev) - creator and maintainer

This repository is managed under the MIT license.

© 2022 PteroPackages
