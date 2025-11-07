{ pkgs ? import <nixpkgs> {} }:

{
    send = pkgs.stdenv.mkDerivation {
        pname = "python-send";
        version = "1.0.0";
        src = ./.;
        
        buildInputs = [ 
            pkgs.python3
        ];

        installPhase = ''
            runHook preInstall
            
            mkdir -p $out/bin
            cp send.py $out/bin/
            cp chunk2.bin $out/bin/
            chmod +x $out/bin/send.py
            patchShebangs $out/bin/
            
            runHook postInstall
        '';
    };

    serve = pkgs.stdenv.mkDerivation {
        pname = "python-serve";
        version = "1.0.0";
        src = ./.;

        buildInputs = [ 
            pkgs.python3
        ];
        
        installPhase = ''
            runHook preInstall
            
            mkdir -p $out/bin
            cp serve.py $out/bin/
            cp chunk2.bin $out/bin/
            chmod +x $out/bin/serve.py
            patchShebangs $out/bin/
            
            runHook postInstall
        '';
    };
}