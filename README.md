# A NixOS template on Gitpod

This is a [nix operating system](https://nixos.org/) template configured for ephemeral nix based development environments on [Gitpod](https://www.gitpod.io/).

## Next Steps

Click the button below to start a new development environment:

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/3waffel/template-nixos)

## Notes & caveats

Host `/workspace` dir is mounted inside guest, docker is installed and user-groups are mapped.

You can press `Ctrl + a` and then `x` to terminate/exit NixOS. You may run `make start` to restart it.

NixOS is configured as per [./configuration.nix](./configuration.nix), you can modify it as needed.

See also: [An opinionated guide for developers getting things done using the nix ecosystem](https://nix.dev/).
