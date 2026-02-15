{
  perSystem =
    { pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          zensical
          pandoc
          typst
        ];
      };
    };
}
