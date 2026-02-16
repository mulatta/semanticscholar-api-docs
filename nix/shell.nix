{
  perSystem =
    { pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          hurl
        ];
      };
      devShells.docs = pkgs.mkShell {
        packages = with pkgs; [
          zensical
        ];
      };
    };
}
