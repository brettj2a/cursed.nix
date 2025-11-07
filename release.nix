let
    sources = import ./npins;
    pkgs = import sources.nixpkgs { };

    aarch64Pkgs = import sources.nixpkgs {
        crossSystem = pkgs.lib.systems.examples.aarch64-multiplatform;
    };
    staticPkgs = pkgs.pkgsStatic;

    go-curse = pkgs.callPackage ./gosrc { inherit pkgs; };
    go-send = go-curse.send;
    go-serve = go-curse.serve;

    lua-curse = pkgs.callPackage ./luasrc { inherit pkgs; };
    lua-send = lua-curse.send;
    lua-serve = lua-curse.serve;

    python-curse = pkgs.callPackage ./pysrc { inherit pkgs; };
    python-send = python-curse.send;
    python-serve = python-curse.serve;

    rust-curse = pkgs.rustPlatform.buildRustPackage {
        pname = "rust-curse";
        version = "1.0.0";
        src = ./.;
        cargoLock.lockFile = ./Cargo.lock;
        
        postPatch = ''
            mkdir -p src
            ln -sf ${./rustsrc/main.rs} src/main.rs
        '';
    };

    # Cross-compiled rust-curse for aarch64-linux
    rust-curse-aarch64 = aarch64Pkgs.rustPlatform.buildRustPackage {
        pname = "rust-curse";
        version = "1.0.0";
        src = ./.;
        cargoLock.lockFile = ./Cargo.lock;
        
        postPatch = ''
            mkdir -p src
            ln -sf ${./rustsrc/main.rs} src/main.rs
        '';
    };

    # Statically linked rust-curse
    rust-curse-static = staticPkgs.rustPlatform.buildRustPackage {
        pname = "rust-curse-static";
        version = "1.0.0";
        src = ./.;
        cargoLock.lockFile = ./Cargo.lock;
        
        postPatch = ''
            mkdir -p src
            ln -sf ${./rustsrc/main.rs} src/main.rs
        '';
    };
in
{
    inherit
        go-send
        go-serve
        lua-send
        lua-serve
        python-send
        python-serve
        rust-curse
        ;

    # Cross-compiled and static versions of rust-curse
    rust-curse-aarch64 = rust-curse-aarch64;
    rust-curse-static = rust-curse-static;
    
    # Patches serve functions to use nix path
    go-serve-patched = go-serve.overrideAttrs (oldAttrs: {
        pname = "go-serve-patched";
        postPatch = oldAttrs.postPatch or "" + ''
            substituteInPlace serve.go \
                --replace-fail "../pysrc/send.py" "${python-send}/bin/send.py"
        '';
    });
    lua-serve-patched = lua-serve.overrideAttrs (oldAttrs: {
        pname = "lua-serve-patched";
        postPatch = oldAttrs.postPatch or "" + ''
            substituteInPlace serve.lua \
                --replace-fail "../gosrc/send" "${go-send}/bin/send"
        '';
    });
    python-serve-patched = python-serve.overrideAttrs (oldAttrs: {
        pname = "python-serve-patched";
        postPatch = oldAttrs.postPatch or "" + ''
            substituteInPlace serve.py \
                --replace-fail "../luasrc/send.lua" "${lua-send}/bin/send.lua"
        '';
    });

    # Add aarch64-linux to rust-curse


    # break-the-curse

    # Create dev shell
    devShell = pkgs.mkShell {
        inputsFrom = [
            go-send
            go-serve
            lua-send
            lua-serve
            python-send
            python-serve
            rust-curse
        ];
        buildInputs = [
            pkgs.cargo
            pkgs.lua
            pkgs.luaPackages.luasocket
            pkgs.python3
            pkgs.go
        ];
    };
}