{
  stdenv,
  fetchFromGitHub,
  lib,
  cmake,
  qt6,
  pkg-config,
}:
stdenv.mkDerivation {
  pname = "skwd-paper-plasma";
  version = "1.0.0-beta.21";

  src = fetchFromGitHub {
    owner = "liixini";
    repo = "skwd-paper-plasma";
    rev = "v1.0.0-beta.21";
    hash = "sha256-wHdkzyEvLlAwEjGz/SEi9antqNBWLTLAHBf/loJXovQ=";
  };

  nativeBuildInputs = [
    cmake
    qt6.qtbase
    qt6.qtdeclarative
    qt6.wrapQtAppsHook
    pkg-config
  ];

  postInstall = ''
    mkdir -p $out/share/licenses/skwd-paper-plasma

    cp -r $src/LICENSE $out/share/licenses/skwd-paper-plasma/
  '';

  meta = {
    description = "KDE Plasma wallpaper integration for Skwd Paper";
    homepage = "https://github.com/liixini/skwd-wall";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [
      futurekismo
      HomieDerPrakti
    ];
    platforms = [ "x86_64-linux" ];
  };
}
