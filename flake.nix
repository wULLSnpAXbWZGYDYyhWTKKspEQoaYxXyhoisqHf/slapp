{
  description = "slapp prints salted sha1 of user's password for ldap purposes";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  outputs = inputs @ {
    self,
    nixpkgs,
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    # Nixpkgs instantiated for supported system types.
    nixpkgsFor = forAllSystems (system:
      import nixpkgs {
        inherit system;
        overlays = [
          # no overlay imports atm
        ];
      });

    projname = "slapp";
  in {
    formatter = forAllSystems (
      system:
        nixpkgsFor.${system}.alejandra
    );

    devShells = forAllSystems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
          ];
        };
        pyEnv = pkgs.python3.withPackages (
          packages:
            with packages; [
              pip
              passlib
            ]
        );
      in {
        default = with pkgs;
          mkShell
          {
            name = "${projname}";

            shellHook = ''
              echo " -- in ${projname} dev shell..."
            '';
            postShellHook = ''
              # allow pip to install wheels
              unset SOURCE_DATE_EPOCH
              unset LD_PRELOAD

              PYTHONPATH=${pkgs.python3.sitePackages}:$PYTHONPATH
            '';

            buildInputs = [
              # python3Packages.pip
              pyEnv
            ];
            nativeBuildInputs = [
            ];
            packages =
              [
                cachix

                ruff # black-compatible Python linter
              ]
              ++ (
                if stdenv.isLinux
                then [
                  # linux-specific pkgs here
                ]
                else []
              );
          };
      }
    );
  };
}
