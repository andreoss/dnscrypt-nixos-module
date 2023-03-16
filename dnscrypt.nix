{ config, lib, pkgs, ... }:

with lib;

let cfg = config.networking.dns-crypt;
in {
  options.networking.dns-crypt = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    proxy-port = mkOption {
      type = types.int;
      default = 5553;
    };
    interface = mkOption {
      type = types.str;
      default = "127.0.0.1";
    };
  };
  config = {
    services = {
      unbound = mkIf cfg.enable {
        enable = true;
        resolveLocalQueries = true;
        enableRootTrustAnchor = false;
        settings = {
          server = {
            access-control = [ "127.0.0.0/8 allow" "192.168.99.0/28 allow" ];
            do-not-query-localhost = "no";
            hide-identity = "yes";
            hide-version = "yes";
            interface = [ "${cfg.interface}" "192.168.99.1" ];
            minimal-responses = "yes";
            prefetch-key = "yes";
            prefetch = "yes";
            verbosity = 4;
          };
          forward-zone = [{
            name = ".";
            forward-addr =
              [ "${cfg.interface}@${builtins.toString cfg.proxy-port}" ];
          }];
        };
      };
      dnscrypt-proxy2 = mkIf cfg.enable {
        enable = true;
        settings = {
          ipv6_servers = false;
          require_dnssec = true;
          listen_addresses =
            [ "${cfg.interface}:${builtins.toString cfg.proxy-port}" ];
          sources.public-resolvers = {
            urls = [
              "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
              "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
            ];
            cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
            minisign_key =
              "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
          };
        };
      };
    };
    systemd.services.unbound =
      mkIf cfg.enable { partOf = [ "network.target" ]; };
    systemd.services.dnscrypt-proxy2 = mkIf cfg.enable {
      requires = [ "unbound.service" ];
      partOf = [ "network.target" ];
    };
    networking = mkIf cfg.enable {
      networkmanager = { insertNameservers = [ "${cfg.interface}" ]; };
      nameservers = [ "${cfg.interface}" ];
      dhcpcd = {
        extraConfig = ''
          duid
          noarp
          static domain_name_servers=${cfg.interface}
        '';
      };
    };
    environment = {
      etc = mkIf cfg.enable {
        "resolv.conf" = {
          mode = "0444";
          source = lib.mkOverride 0
            (pkgs.writeText "resolv.conf" "nameserver ${cfg.interface}");
        };
      };
    };
  };
}
