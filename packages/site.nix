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
          zensical build -f zensical.toml --clean
          zensical build -f zensical-en.toml --clean
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall
          mkdir -p $out
          cp -r site/ko $out/ko
          cp -r site/en $out/en

          # Root redirect (relative path — works regardless of subpath)
          cat > $out/index.html << 'HTML'
          <!DOCTYPE html>
          <html>
          <head><meta http-equiv="refresh" content="0; url=ko/"></head>
          <body><a href="ko/">Redirect</a></body>
          </html>
          HTML

          # Language root redirects to landing page
          cat > $out/ko/index.html << 'HTML'
          <!DOCTYPE html>
          <html>
          <head><meta http-equiv="refresh" content="0; url=00-index/"></head>
          <body><a href="00-index/">Redirect</a></body>
          </html>
          HTML
          cat > $out/en/index.html << 'HTML'
          <!DOCTYPE html>
          <html>
          <head><meta http-equiv="refresh" content="0; url=00-index/"></head>
          <body><a href="00-index/">Redirect</a></body>
          </html>
          HTML

          runHook postInstall
        '';

        dontFixup = true;
      };
    };
}
