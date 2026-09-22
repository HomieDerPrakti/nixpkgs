{
  lib,
  rustPlatform,
  pkg-config,
  fetchFromGitHub,
  libglvnd,
  libxkbcommon,
  vulkan-loader,
  wayland,
  alsa-lib,
  dav1d,
  libdrm,
  libpulseaudio,
  libva-minimal,
  libyuv,
  shaderc,
  stdenv,
  zlib,
  skwd-deck,
  skwd-lens,
  skwd-lens-model,
  skwd-paper-v2,
  bash,
  coreutils,
  util-linux,
  makeBinaryWrapper,
  nixosTests,
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
  pname = "skwd-wall-v2";
  version = "1.0.0-beta.21";
  src = fetchFromGitHub {
    owner = "liixini";
    repo = "skwd-wall";
    rev = "v1.0.0-beta.21";
    hash = "sha256-D0yVmvkMnFJq228gZiIxiC/zeph6STGCGByKeB02Los=";
  };

  postUnpack = ''
    cp -r --no-preserve=mode,ownership ${skwd-deck.src} $NIX_BUILD_TOP/skwd-deck
    cp -r --no-preserve=mode,ownership ${skwd-lens.src} $NIX_BUILD_TOP/skwd-lens
  '';

  cargoHash = "sha256-fMkWdt0BzSTyKzoS7rhfjA3c9yb+HYS+5mSBSMTb1XY=";

  nativeBuildInputs = [
    pkg-config
    makeBinaryWrapper
  ];

  buildInputs = [
    alsa-lib
    dav1d
    libdrm
    libpulseaudio
    libva-minimal
    libyuv
    shaderc
    stdenv.cc.cc.lib
    zlib
  ]
  ++ graphicsRuntime;

  cargoBuildFlags = [
    "--manifest-path Cargo.toml"
    "--package skwd-wall"
    "--bin skwd-wall"
  ];

  cargoTestFlags = [
    "--manifest-path Cargo.toml"
    "--package skwd-wall"
    "--bin skwd-wall"
  ];

  postInstall = ''
    mv $out/bin/skwd-wall $out/bin/skwd-wall-v2

    mkdir -p $out/share/icons/hicolor/scalable/apps
    mkdir -p $out/share/{applications,metainfo}
    mkdir -p $out/share/licenses/skwd-wall-v2/third-party

    cp -r $src/data/skwd-wall.svg $out/share/icons/hicolor/scalable/apps/skwd-wall-v2.svg
    cp -r $src/data/skwd-wall.desktop $out/share/applications/skwd-wall-v2.desktop
    cp -r $src/data/skwd-wall.metainfo.xml $out/share/metainfo/org.skwd.wall.v2.metainfo.xml
    cp -r $src/LICENSES/* $out/share/licenses/skwd-wall-v2/third-party/
    cp -r $src/LICENSE $out/share/licenses/skwd-wall-v2/
  '';

  postFixup = ''
    for bin in "$out"/bin/skwd-wall-v2; do
      patchelf --add-rpath "${
        lib.makeLibraryPath (
          [
            alsa-lib
          ]
          ++ graphicsRuntime
        )
      }" $bin
    done
    for program in skwd-wall-v2; do
      wrapProgram "$out/bin/$program" \
        --set-default SKWD_LENS_HOME ${skwd-lens-model}/share/skwd-lens/models/semantic \
        --prefix PATH : ${
          lib.makeBinPath [
            skwd-deck
            skwd-paper-v2
            skwd-lens
            bash
            coreutils
            util-linux
          ]
        }
    done
  '';

  propagatedUserEnvPkgs = [
    skwd-paper-v2
    skwd-deck
    skwd-lens
    skwd-lens-model
  ];

  meta = {
    description = "GPU-rendered graphical client for the Skwd wallpaper suite v2";
    homepage = "https://github.com/liixini/skwd-wall";
    license = with lib.licenses; [
      gpl3Plus
      mit
      cc-by-40
      asl20
      ofl
      lib.licenses.zlib
    ];
    maintainers = with lib.maintainers; [
      futurekismo
      HomieDerPrakti
    ];
    mainProgram = "skwd-wall-v2";
    platforms = [ "x86_64-linux" ];
  };

  passthru.tests = [
    nixosTests.skwd-wall-v2
    nixosTests.skwd-wall-v2-module
  ];
}
