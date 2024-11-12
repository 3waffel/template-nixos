FROM gitpod/workspace-base

# Install Nix
ENV USER=gitpod
USER gitpod
RUN curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
  | sh -s -- install --extra-conf "sandbox = false" --no-confirm
COPY configuration.nix /tmp
RUN sudo chmod -R 755 /nix && sudo chown -R gitpod /nix
ENV PATH="${PATH}:/nix/var/nix/profiles/default/bin"
ENV PATH="${PATH}:${HOME}/.nix-profile/bin"
RUN nix profile install nixpkgs#cachix \
  nixpkgs#gitFull \
  nixpkgs#direnv \
  nixpkgs#nixos-generators
RUN cachix use cachix
RUN (cd /tmp && nixos-generate -c ./configuration.nix -f vm-nogui -o ./dist)
RUN mkdir -p $HOME/.config/direnv \
  && printf '%s\n' '[whitelist]' 'prefix = [ "/workspace"] ' >> $HOME/.config/direnv/config.toml \
  && printf '%s\n' 'source <(direnv hook bash)' >> $HOME/.bashrc.d/999-direnv

# Install qemu
RUN sudo upgrade-packages
RUN sudo install-packages qemu qemu-system-x86 libguestfs-tools sshpass netcat
