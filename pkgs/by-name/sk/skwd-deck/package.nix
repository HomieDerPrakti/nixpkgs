{
  lib,
  coreutils,
  fetchFromGitHub,
  libglvnd,
  libxkbcommon,
  vulkan-loader,
  wayland,
  rustPlatform,
  bash,
  alsa-lib,
  dav1d,
  libyuv,
  libdrm,
  libpulseaudio,
  libva-minimal,
  shaderc,
  stdenv,
  zlib,
  skwd-paper-v2,
  skwd-lens,
  skwd-paper-plasma,
  ffmpeg,
  cmake,
  git,
  python3,
  pkg-config,
  clang,
  libclang,
  util-linux,
  makeBinaryWrapper,
  skwd-lens-model,
}:
let
  graphicsRuntime = [
    libglvnd
    libxkbcommon
    vulkan-loader
    wayland
  ];
in
rustPlatform.buildRustPackage {
  pname = "skwd-deck";
  version = "1.0.0-beta.21";
  src = fetchFromGitHub {
    owner = "liixini";
    repo = "skwd-deck";
    rev = "v1.0.0-beta.21";
    hash = "sha256-sMZqDxfoCRJDA5sr4tP51CM0TAqD95wOHrnzj7UpT9Y=";
  };

  cargoHash = "sha256-maS01GdXxBr/wFPetWpnZbjTIyH6pmzcJs+gBekwEg4=";

  postUnpack = ''
    cp -r --no-preserve=mode,ownership ${skwd-paper-v2.src} $NIX_BUILD_TOP/skwd-paper
    cp -r --no-preserve=mode,ownership ${skwd-lens.src} $NIX_BUILD_TOP/skwd-lens
  '';

  postPatch = ''
    while IFS= read -r -d "" file; do
      substituteInPlace "$file" --replace-quiet '#!/bin/sh' '#!${bash}/bin/sh'
    done < <(grep -lZ 'bin/true' $(find . -name '*.rs'))
    while IFS= read -r -d "" file; do
      substituteInPlace "$file" --replace-quiet '/bin/true' '${coreutils}/bin/true'
    done < <(grep -lZ 'bin/true' $(find . -name '*.rs'))
  '';

  nativeBuildInputs = [
    pkg-config
    cmake
    git
    python3
    clang
    rustPlatform.bindgenHook
    libclang
    makeBinaryWrapper
    coreutils
  ];

  nativeCheckInputs = [
    coreutils
  ];

  postInstall = ''
    mkdir -p $out/share/systemd/user
    mkdir -p $out/share/skwd-wall-v2/data
    mkdir -p $out/share/licenses/skwd-deck/third-party
    mkdir -p $out/lib/systemd

    cp -r $src/data/skwd-walld.service $out/share/systemd/user/
    cp -r $src/data/matugen $out/share/skwd-wall-v2/data/
    cp -r $src/LICENSES/{Apache-2.0.txt,cosmic-protocols.txt,MIT.txt} $out/share/licenses/skwd-deck/third-party/
    cp -r $src/LICENSE $out/share/licenses/skwd-deck/
  '';

  postFixup = ''
    for bin in "$out"/bin/skwd-walld; do
      patchelf --add-rpath "${
        lib.makeLibraryPath (
          [
            alsa-lib
          ]
          ++ graphicsRuntime
        )
      }" $bin
    done
    for program in skwd-walld skwd-wall-scan; do
        wrapProgram "$out/bin/$program" \
          --set-default SKWD_LENS_HOME ${skwd-lens-model}/share/skwd-lens/models/semantic \
          --prefix PATH : "$out/bin:${
            lib.makeBinPath [
              skwd-paper-v2
              skwd-lens
              bash
              coreutils
              util-linux
            ]
          }"
    done

  '';

  buildInputs = [
    alsa-lib
    ffmpeg
    dav1d
    libyuv
    libdrm
    libpulseaudio
    libva-minimal
    shaderc
    stdenv.cc.cc.lib
    zlib
    skwd-paper-v2
  ]
  ++ graphicsRuntime;

  cargoBuildFlags = [
    "--manifest-path Cargo.toml"
    "--package skwd-walld"
    "--package skwd-wall-scan"
    "--package skwd-wall-effects"
    "--package skwd-helm"
  ];

  cargoTestFlags = [
    "--manifest-path Cargo.toml"
    "--package skwd-walld"
    "--package skwd-wall-scan"
    "--package skwd-wall-effects"
    "--package skwd-helm"
  ];

  meta = {
    description = "Control daemon and tools for the Skwd wallpaper suite v2";
    homepage = "https://github.com/liixini/skwd-wall";
    license = with lib.licenses; [
      gpl3Plus
      mit
      asl20
      hpnd
    ];
    maintainers = with lib.maintainers; [
      futurekismo
      HomieDerPrakti
    ];
    mainProgram = "skwd-walld";
    platforms = [ "x86_64-linux" ];
  };
}
