{
  lib,
  rustPlatform,
  pkg-config,
  fetchFromGitHub,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "skwd-lens";
  version = "1.0.0-beta.22";

  src = fetchFromGitHub {
    owner = "liixini";
    repo = "skwd-lens";
    rev = "v${finalAttrs.version}";
    hash = "sha256-pR0ws+dROtbS9ozCdcwBxP5rrd90alDxmO1IOVwKTK8=";
  };

  cargoHash = "sha256-lfnEOtJzPEzr+LmRh9WeFpEHmbk1emsjqZlRLcdX/IU=";

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

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=unstable" ];
  };

})
