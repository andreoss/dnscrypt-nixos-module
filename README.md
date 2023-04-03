# dnscrypt-nixos-module

NixOS module to enable DNS configuration with unbound and https://github.com/DNSCrypt/dnscrypt-proxy


## Installation

### Add this repo as an input to `flake.nix`
```
inputs = {
      ...
      dnscrypt-module.url = "github:andreoss/dnscrypt-nixos-module";
      ...
};
```

### Add the module to the module list 

```
 modules = [ inputs.dnscrypt-module.nixosModules.default ... ];
```

### Enable `network.dns-crypt` option

```
  networking = {
    dns-crypt.enable = true;
  };
```
