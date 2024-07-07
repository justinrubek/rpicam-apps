{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    libcamera = {
      url = "github:justinrubek/libcamera";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux"];
      perSystem = {
        config,
        pkgs,
        system,
        inputs',
        self',
        ...
      }: {
        packages = {
          rpicam-apps = pkgs.stdenv.mkDerivation {
            pname = "libcamera-apps";
            version = "v1.5.0";
            src = ./.;

            nativeBuildInputs = [pkgs.meson pkgs.pkg-config];
            buildInputs = [
              pkgs.xorg.libX11
              pkgs.xorg.libXcursor
              pkgs.xorg.libXrandr
              pkgs.xorg.libXi
              pkgs.ffmpeg
              pkgs.libdrm
              pkgs.libjpeg
              pkgs.libtiff
              inputs'.libcamera.packages.libcamera
              pkgs.libepoxy
              pkgs.boost
              pkgs.libexif
              pkgs.libpng
              pkgs.ninja
            ];
            mesonFlags = [
              "-Denable_qt=disabled"
              "-Denable_opencv=disabled"
              "-Denable_tflite=disabled"
              "-Denable_drm=enabled"
              "-Denable_hailo=disabled"
              "-Denable_egl=disabled"
            ];
            # Meson is no longer able to pick up Boost automatically.
            # https://github.com/NixOS/nixpkgs/issues/86131
            BOOST_INCLUDEDIR = "${pkgs.lib.getDev pkgs.boost}/include";
            BOOST_LIBRARYDIR = "${pkgs.lib.getLib pkgs.boost}/lib";
          };
        };
      };
    };
}
