{
  description = "DNS Crypt module.";
  outputs =
    { self, nixpkgs }:
    {
      nixosModules.default = import ./dnscrypt.nix;
      nixosConfigurations.test = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.outputs.nixosModules.default
          (
            {
              config,
              pkgs,
              lib,
              ...
            }:
            {
              system.stateVersion = "23.05";
              services.getty.autologinUser = "root";
              environment.systemPackages = with pkgs; [ dig ];
              networking = {
                dns-crypt.enable = true;
              };
            }
          )
        ];
      };
    };
}
