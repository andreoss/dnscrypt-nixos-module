{
  description = "DNS Crypt module.";
  outputs = { self, nixpkgs }: { nixosModules.default = import ./dnscrypt.nix; };
}
