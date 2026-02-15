{ self, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      docs = self + "/docs";
      config = self + "/zensical.toml";

      pdfDir = self + "/packages/pdf";
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

      fonts = pkgs.symlinkJoin {
        name = "pdf-fonts";
        paths = [
          pkgs.noto-fonts-cjk-sans
          pkgs.noto-fonts
          pkgs.noto-fonts-extra
        ];
      };
    in
    {
      packages = {
        site = pkgs.runCommand "s2-api-docs-site" { nativeBuildInputs = [ pkgs.zensical ]; } ''
          mkdir -p work/docs
          cp -r ${docs}/* work/docs/
          cp ${config} work/zensical.toml
          cd work
          zensical build --clean
          cp -r site $out
        '';

        pdf =
          pkgs.runCommand "s2-api-guide-pdf"
            {
              nativeBuildInputs = [
                pkgs.pandoc
                pkgs.typst
              ];
            }
            ''
              mkdir -p $out
              cd ${docs}
              pandoc --file-scope \
                ${builtins.concatStringsSep " " docFiles} \
                --pdf-engine=typst \
                --template=${pdfDir}/template.typ \
                --pdf-engine-opt="--font-path=${fonts}/share/fonts" \
                --lua-filter=${pdfDir}/strip-nav.lua \
                -o $out/s2-api-guide.pdf
            '';
      };
    };
}
