{ 
    pkgs ? import <nixpkgs> {}
}:

{
    serve = pkgs.buildGoModule {
        pname = "go-serve";
        version = "1.0.0";
        src = ./.;
        vendorHash = null;
        subPackages = [ "serve.go"];

        postInstall = ''
            cp ./chunk3.bin $out/bin/chunk3.bin
        '';
    };

    send = pkgs.buildGoModule {
        pname = "go-send";
        version = "1.0.0";
        src = ./.;
        vendorHash = null;
        subPackages = [ "send.go"];

        postInstall = ''
            cp ./chunk3.bin $out/bin/chunk3.bin
        '';
    };
}