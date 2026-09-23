{
  stdenv,
  fetchurl,
  autoPatchelfHook,
  lib,
}:
stdenv.mkDerivation {
  pname = "skwd-lens-model";
  version = "1.0.0";
  src = fetchurl {
    url = "https://github.com/liixini/skwd-wall/releases/download/v1.0.0-beta.21/skwd-model-nixos-x86_64-1.0.0-beta.21.tar.gz";
    hash = "sha256-s9en+M1rb2KPQz3/T7MVexO4+ZxvZqZetZEfEJVlZSU=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  preFixup = ''
    while IFS= read -r -d "" file; do
      if isELF "$file"; then
        patchelf --remove-rpath "$file"
      fi
    done < <(find "$out" -type f -print0)
  '';

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -a . "$out/"

    chmod -R u+w $out

    runHook postInstall
  '';

  meta = {
    description = "Default SigLIP 2 semantic model pack for Skwd Lens";
    homepage = "https://github.com/liixini/skwd-wall";
    license = with lib.licenses; [
      asl20
      mit
      cc-by-40
    ];
    maintainers = with lib.maintainers; [
      HomieDerPrakti
      futurekismo
    ];
    sourceProvenance = with lib.sourceType; [
      binaryNativeCode
    ];
    platforms = [ "x86_64-linux" ];
  };
}
