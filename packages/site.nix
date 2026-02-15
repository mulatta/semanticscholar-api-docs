{
  perSystem =
    { pkgs, ... }:
    {
      packages.site = pkgs.stdenvNoCC.mkDerivation {
        pname = "s2-api-guide-site";
        version = "0.1.0";
        src = ../.;

        nativeBuildInputs = [ pkgs.zensical ];

        buildPhase = ''
          runHook preBuild
          zensical build --clean
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall
          mv site $out
          runHook postInstall
        '';

        dontFixup = true;
      };
    };
}
