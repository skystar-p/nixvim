{
  lib,
  config,
  helpers,
  pkgs,
  ...
}:
with lib;
let
  cmpLib = import ../cmp-helpers.nix {
    inherit
      lib
      config
      helpers
      pkgs
      ;
  };
  cmpSourcesPluginNames = attrValues (import ../sources.nix);
  # dirty patch to use forked copilot-cmp
  vimPluginFromGitHub =
    {
      owner,
      repo,
      rev,
      hash,
    }:
    pkgs.vimUtils.buildVimPlugin {
      name = repo;
      src = pkgs.fetchFromGitHub {
        inherit
          owner
          repo
          rev
          hash
          ;
      };
    };
  copilotCmp = cmpLib.mkCmpSourcePlugin {
    name = "copilot-cmp";
    useDefaultPackage = false;
    extraPlugins = [
      (vimPluginFromGitHub {
        owner = "JosefLitos";
        repo = "cmp-copilot";
        rev = "7ea51184eb21c4633adc48eccd0ed4087168432e";
        hash = "sha256-Yu2UHZZgD52zI/uhhFL4LZMT5jcBF/sZm0Mul+tCgQ8=";
      })
    ];
  };
  pluginModules = map (
    name: if name == "cmp_copilot" then copilotCmp else (cmpLib.mkCmpSourcePlugin { inherit name; })
  ) cmpSourcesPluginNames;
in
{
  # For extra cmp plugins
  imports = [
    ./codeium-nvim.nix
    ./copilot-cmp.nix
    ./cmp-fish.nix
    ./cmp-git.nix
    ./cmp-tabby.nix
    ./cmp-tabnine.nix
    ./crates-nvim.nix
  ] ++ pluginModules;
}
