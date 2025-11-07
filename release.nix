let
    pkgs = import <nixpkgs> { };
in
{
    devShell = pkgs.mkShell {
        buildInputs = [
            pkgs.cargo
            pkgs.lua
            pkgs.luaPackages.luasocket
            pkgs.python3
            pkgs.go
        ];
    };
}