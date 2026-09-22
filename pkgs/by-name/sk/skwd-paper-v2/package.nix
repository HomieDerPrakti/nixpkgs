{
  libglvnd,
  libxkbcommon,
  vulkan-loader,
  vulkan-headers,
  wayland,
  wayland-protocols,
  rustPlatform,
  fetchFromGitHub,
  lib,
  python3,
  bash,
  pkg-config,
  cmake,
  git,
  alsa-lib,
  ffmpeg_9,
  dav1d,
  libyuv,
  shaderc,
  zlib,
  libdrm,
  libva-minimal,
  libpulseaudio,
  stdenv,
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
  pname = "skwd-paper-v2";
  version = "1.0.0-beta.21";
  src = fetchFromGitHub {
    owner = "liixini";
    repo = "skwd-paper";
    rev = "v1.0.0-beta.21";
    hash = "sha256-0AoKNy+2UNgAu88Wbd2S8lvY39W7+RpCXXN1KdiR1bI=";
  };
  cargoHash = "sha256-RzOO+8wRiPvy9bWD4qtEr/uYY4JzdVDvC6ZeB2Si3x4=";
  VULKAN_INCLUDE_DIR = "${vulkan-headers}/include";

  postPatch = ''
    substituteInPlace crates/paper-cli/src/server_tests.rs \
      --replace-fail '#!/usr/bin/python3' '#!${python3}/bin/python3'
    while IFS= read -r -d ""; do
      substituteInPlace "$REPLY" --replace-quiet '#!/bin/sh' '#!${bash}/bin/sh'
    done < <(find . -name '*.rs' -print0)
  '';

  nativeBuildInputs = [
    pkg-config
    wayland
    wayland-protocols
    cmake
    rustPlatform.bindgenHook
    git
    python3
    shaderc
    zlib
  ];

  buildInputs = [
    alsa-lib
    ffmpeg_9
    dav1d
    libyuv
    libdrm
    libpulseaudio
    libva-minimal
    shaderc
    stdenv.cc.cc.lib
    zlib
  ]
  ++ graphicsRuntime;

  postFixup = ''
    for bin in "$out"/bin/skwd-wall-vk "$out"/bin/skwd-paper-v2; do
      patchelf --add-rpath "${
        lib.makeLibraryPath (
          [
            alsa-lib
          ]
          ++ graphicsRuntime
        )
      }" $bin
    done
  '';

  cargoBuildFlags = [
    "--manifest-path Cargo.toml"
    "--package skwd-paper"
    "--package paper-tinier"
    "--package skwd-wall-vk"
    "--package skwd-wall-still"
  ];

  cargoTestFlags = [
    "--manifest-path Cargo.toml"
    "--package skwd-paper"
    "--package paper-tinier"
    "--package skwd-wall-vk"
    "--package skwd-wall-still"
  ];

  postInstall = ''
    mv $out/bin/skwd-paper $out/bin/skwd-paper-v2
    mkdir -p $out/share/licenses/skwd-paper-v2/third-party
    cp -r $src/LICENSE $out/share/licenses/skwd-paper-v2/
    cp -r $src/LICENSES/{OpenH264-BSD-2-Clause.txt,dav1d-BSD-2-Clause.txt,libyuv-BSD-3-Clause.txt} $out/share/licenses/skwd-paper-v2/third-party
  '';

  meta = {
    description = "Still, video, and Wallpaper Engine renderers for Skwd";
    homepage = "https://github.com/liixini/skwd-wall";
    license = with lib.licenses; [
      gpl3Plus
      bsd2
      bsd3
    ];
    maintainers = with lib.maintainers; [
      futurekismo
      HomieDerPrakti
    ];
    mainProgram = "skwd-paper-v2";
    platforms = [ "x86_64-linux" ];
  };
}
