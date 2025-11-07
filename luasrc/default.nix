{ pkgs ? import <nixpkgs> {} }:
let
  luaWithDeps = pkgs.lua.withPackages (ps: with ps; [
    luasocket
  ]);
in {
  send = pkgs.stdenv.mkDerivation {
    pname = "lua-send";
    version = "0.0.0-1";
    src = ./.;
    
    buildInputs = [ 
      luaWithDeps
    ];
    
    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      
      # Install as a library
      cp send.lua $out/bin/send.lua
      cp chunk1.bin $out/bin/chunk1.bin

      # Create executable wrapper
      cat > $out/bin/send << EOF
      #!/bin/sh
      exec ${luaWithDeps}/bin/lua $out/bin/send.lua "\$@"
      EOF
      chmod +x $out/bin/send

      runHook postInstall
    '';
  };

  serve = pkgs.stdenv.mkDerivation {
    pname = "lua-serve";
    version = "0.0.0-1";
    src = ./.;


    buildInputs = [ 
      luaWithDeps
    ];
    
    # Note: This assumes gosrc/send will be in PATH when run
    # You may need to modify this to find the correct gosrc path
    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      
      # Install as a library
      cp serve.lua $out/bin/serve.lua
      cp chunk1.bin $out/bin/chunk1.bin
      
      # Create executable wrapper
      cat > $out/bin/serve << EOF
      #!/bin/sh
      exec ${luaWithDeps}/bin/lua $out/bin/serve.lua "\$@"
      EOF
      chmod +x $out/bin/serve

      runHook postInstall
    '';
  };

}