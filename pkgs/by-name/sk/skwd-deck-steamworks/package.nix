{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  python3,
  bash,
  skwd-paper-v2,
  skwd-lens,
  skwd-deck,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "skwd-deck-steamworks";
  version = "1.0.0-beta.22";
  src = fetchFromGitHub {
    owner = "liixini";
    repo = "skwd-deck";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Xopj0qVhr5prljHv2qGRMe694B8CFWpMr2sTYB5DbTQ=";
  };
  cargoHash = "sha256-fvRh08ndTnWx7SoLFlEdUaT6SFVD8AheocenxxxeHFE=";

  postUnpack = ''
    cp -r --no-preserve=mode,ownership ${skwd-paper-v2.src} $NIX_BUILD_TOP/skwd-paper
    cp -r --no-preserve=mode,ownership ${skwd-lens.src} $NIX_BUILD_TOP/skwd-lens
  '';

  postPatch = ''
    while IFS= read -r -d ""; do
      substituteInPlace "$REPLY" --replace-quiet '#!/bin/sh' '#!${bash}/bin/sh'
    done < <(grep -n 'bin/sh' $(find . -name '*.rs'))
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  cargoBuildFlags = [
    "--manifest-path Cargo.toml"
    "--package skwd-steam"
    "--bin skwd-steam"
  ];

  cargoTestFlags = [
    "--manifest-path Cargo.toml"
    "--package skwd-steam"
    "--bin skwd-steam"
  ];

  meta = {
    description = "Optional Steam Client Workshop backend for Skwd Deck";
    homepage = "https://github.com/liixini/skwd-wall";
    license = with lib.licenses; [
      gpl3Plus
      valveSDK
    ];
    maintainers = with lib.maintainers; [
      futurekismo
      HomieDerPrakti
    ];
    mainProgram = "skwd-steam";
    platforms = [ "x86_64-linux" ];
  };

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=unstable" ];
  };
})
