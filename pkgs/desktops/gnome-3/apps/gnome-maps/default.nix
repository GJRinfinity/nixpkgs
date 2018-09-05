{ stdenv, fetchurl, meson, ninja, gettext, python3, pkgconfig, gnome3, gtk3
, gobjectIntrospection, gdk_pixbuf, librsvg, libgweather
, geoclue2, wrapGAppsHook, folks, libchamplain, gfbgraph, libsoup
, webkitgtk, gjs, libgee, geocode-glib, evolution-data-server, gnome-online-accounts }:

let
  pname = "gnome-maps";
  version = "3.30.1";
in stdenv.mkDerivation rec {
  name = "${pname}-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${stdenv.lib.versions.majorMinor version}/${name}.tar.xz";
    sha256 = "0g3bm2ad4d0m879cn1wwxikk69r1xd357him2prbbhy9b5i8bjf8";
  };

  doCheck = true;

  nativeBuildInputs = [ meson ninja pkgconfig gettext python3 wrapGAppsHook ];
  buildInputs = [
    gobjectIntrospection
    gtk3 geoclue2 gjs libgee folks gfbgraph
    geocode-glib libchamplain libsoup
    gdk_pixbuf librsvg libgweather
    gnome3.gsettings-desktop-schemas evolution-data-server
    gnome-online-accounts gnome3.defaultIconTheme
    webkitgtk
  ];

  postPatch = ''
    chmod +x meson_post_install.py # patchShebangs requires executable file
    patchShebangs meson_post_install.py

    # The .service file isn't wrapped with the correct environment
    # so misses GIR files when started. By re-pointing from the gjs
    # entry point to the wrapped binary we get back to a wrapped
    # binary.
    substituteInPlace "data/org.gnome.Maps.service.in" \
        --replace "Exec=@pkgdatadir@/org.gnome.Maps" \
                  "Exec=$out/bin/gnome-maps"
  '';

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
      attrPath = "gnome3.${pname}";
    };
  };

  meta = with stdenv.lib; {
    homepage = https://wiki.gnome.org/Apps/Maps;
    description = "A map application for GNOME 3";
    maintainers = gnome3.maintainers;
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}
