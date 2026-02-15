{
  perSystem =
    { pkgs, ... }:
    let
      typstWithPkgs = pkgs.typst.withPackages (p: [ p.cmarker ]);

      mkPdf =
        lang:
        pkgs.stdenvNoCC.mkDerivation {
          pname = "s2-api-guide-${lang}";
          version = "0.1.0";
          src = ../.;

          nativeBuildInputs = [
            typstWithPkgs
            pkgs.d2coding
          ];

          buildPhase = ''
            runHook preBuild
            export XDG_CACHE_HOME="$TMPDIR/cache"
            typst compile \
              --root . \
              --font-path ${pkgs.d2coding}/share/fonts/truetype \
              typst/${lang}.typ s2-api-guide-${lang}.pdf
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            install -Dm644 s2-api-guide-${lang}.pdf $out/s2-api-guide-${lang}.pdf
            runHook postInstall
          '';

          dontFixup = true;
        };
    in
    {
      packages = {
        pdf-ko = mkPdf "ko";
        pdf-en = mkPdf "en";
      };
    };
}
