{ pkgs, lib, ... }: {
  nix = {
    package = pkgs.nixVersions.latest;
    settings = {
      auto-optimise-store = true;
      substituters = lib.mkBefore [
        "https://nix-community.cachix.org"
        "https://3waffel.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "3waffel.cachix.org-1:Tm5oJGJA8klOLa4dYRJvoYWQIpItX+0w9KvoRP8Z2mc="
      ];
      trusted-users = ["root" "@wheel"];
      experimental-features = ["nix-command" "flakes"];
      warn-dirty = false;
      system-features = ["kvm" "big-parallel"];
    };
  };

  system.stateVersion = "22.11";
  networking.firewall.enable = false;
  virtualisation.docker.enable = true;

  services.openssh = {
    openFirewall = true;
    enable = true;
    listenAddresses = [{
      addr = "0.0.0.0";
      port = 22;
    }];
    settings.PasswordAuthentication = true;
  };
  services.getty.autologinUser = "gitpod";

  environment.systemPackages = with pkgs; [
    curl
    coreutils
    direnv
    findutils
    gitAndTools.gitFull
    home-manager
    htop
    inetutils
    sudo
    tmux
    vim
    python3
    unzip
    wget
  ];

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  users = {
    groups.gitpod = {
      gid = 33333;
      members = [ "gitpod" ];
    };

    users = {
      root.password = "root";
      gitpod = {
        extraGroups = [ "gitpod" "wheel" ];
        uid = 33333;
        group = "gitpod";
        isNormalUser = true;
        password = "gitpod";
      };
    };
  };

  system.activationScripts.workspaceLogin = {
    text = ''
      mkdir -m 0755 -p /workspace
      chown -h gitpod:gitpod /workspace
      mount -t 9p -o trans=virtio,version=9p2000.L,rw host0 /workspace
    '';
  };

  environment.etc."prompt_command".text = ''
    if test $stty_times -gt 3; then {
      PROMPT_COMMAND="$(sed "s|reset||" <<<"$PROMPT_COMMAND")"
    } fi
    stty_times=$((stty_times+1))
    (old="$(stty -g)";stty raw -echo min 0 time 5;printf '\0337\033[r\033[999;999H\033[6n\0338'>/dev/tty; IFS='[;R' read -r _ rows cols _ < /dev/tty;stty "$old";stty cols "$cols" rows "$rows") >/dev/null 2>&1
  '';

  environment.shellInit = ''
    stty_times=1
    alias reset="source /etc/prompt_command"
    PROMPT_COMMAND='reset'
  '';

  environment.extraInit = ''
      source /workspace/.shellhook
  '';
}
