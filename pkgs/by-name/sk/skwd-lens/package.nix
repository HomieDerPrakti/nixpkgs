{
  lib,
  rustPlatform,
  pkg-config,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage {
  pname = "skwd-lens";
  version = "1.0.0-beta.21";
  src = fetchFromGitHub {
    owner = "liixini";
    repo = "skwd-lens";
    rev = "v1.0.0-beta.21";
    hash = "sha256-gKnyv/fYenhrHkYu/r8Vcsmz6Y2GyAhafMAkqD+whpg=";
  };

  cargoHash = "sha256-jbTpGU4+kehtPlDzAnz2cDr32x8DsVNcEuSYpDtr4jM=";

  nativeBuildInputs = [
    pkg-config
  ];

  cargoBuildFlags = [
    "--manifest-path Cargo.toml"
    "--package skwd-lens"
  ];

  cargoTestFlags = [
    "--manifest-path Cargo.toml"
    "--package skwd-lens"
  ];

  postInstall = ''
    mkdir -p $out/share/licenses/skwd-lens/third-party

    cp -r $src/LICENSES/* $out/share/licenses/skwd-lens/third-party/
    cp -r $src/LICENSE $out/share/licenses/skwd-lens/
  '';

  meta = {
    description = "Optional semantic wallpaper search engine for Skwd";
    homepage = "https://github.com/liixini/skwd-wall";
    license = with lib.licenses; [
      gpl3Plus
      asl20
      cc-by-40
      mit
    ];
    maintainers = with lib.maintainers; [
      futurekismo
      HomieDerPrakti
    ];
    mainProgram = "skwd-lens";
    platforms = [ "x86_64-linux" ];
  };
}
