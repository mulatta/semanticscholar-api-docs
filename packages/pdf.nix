{
  perSystem =
    { pkgs, ... }:
    let
      docFiles = [
        "00-index.md"
        "01-overview.md"
        "02-common.md"
        "03-paper-search.md"
        "04-paper-detail.md"
        "05-author.md"
        "06-recommendations.md"
        "07-datasets.md"
        "08-data-models.md"
        "09-appendix.md"
      ];
      inputArgs = builtins.concatStringsSep " " (map (f: "docs/${f}") docFiles);
    in
    {
      packages.pdf = pkgs.stdenvNoCC.mkDerivation {
        pname = "s2-api-guide-pdf";
        version = "0.1.0";
        src = ../.;

        nativeBuildInputs = [
          pkgs.pandoc
          pkgs.typst
          pkgs.d2coding
        ];

        buildPhase = ''
          runHook preBuild

          export TYPST_FONT_PATHS="${pkgs.d2coding}/share/fonts/truetype"

          pandoc \
            --file-scope \
            ${inputArgs} \
            --pdf-engine=typst \
            --template=typst/template.typ \
            --pdf-engine-opt="--font-path=${pkgs.d2coding}/share/fonts/truetype" \
            --lua-filter=typst/strip-nav.lua \
            -o s2-api-guide.pdf

          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall
          mkdir -p $out
          cp s2-api-guide.pdf $out/
          runHook postInstall
        '';

        dontFixup = true;
      };
    };
}
