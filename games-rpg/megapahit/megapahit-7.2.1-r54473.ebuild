# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake unpacker

DESCRIPTION="A fork of the Second Life viewer"
HOMEPAGE="https://megapahit.net"
SRC_URI="
	https://megapahit.net/downloads/${PF}.tar.bz2
	https://github.com/secondlife/3p-colladadom/archive/refs/tags/v2.3-r8.tar.gz -> colladadom-v2.3-r8.tar.gz
	https://github.com/secondlife/3p-cubemap_to_eqr_js/releases/download/v1.1.0-cb8785a/cubemaptoequirectangular-1.1.0-linux64-cb8785a.tar.zst
	https://github.com/secondlife/3p-curl/releases/download/v7.54.1-r1/curl-7.54.1-10342910827-linux64-10342910827.tar.zst
	https://github.com/secondlife/3p-dictionaries/releases/download/v1-a01bb6c/dictionaries-1.a01bb6c-common-a01bb6c.tar.zst
	https://github.com/secondlife/dullahan/releases/download/v1.14.0-r3/dullahan-1.14.0.202408091637_118.4.1_g3dd6078_chromium-118.0.5993.54-linux64-10322607516.tar.zst
	https://github.com/secondlife/3p-emoji-shortcodes/releases/download/v15.3.2-r1/emoji_shortcodes-15.3.2.10207138275-common-10207138275.tar.zst
	https://github.com/secondlife/3p-glh_linear/releases/download/v1.0.1-dev4-984c397/glh_linear-1.0.1-dev4-common-984c397.tar.zst
	https://github.com/secondlife/3p-jpeg_encoder_js/releases/download/v1.0-790015a/jpegencoderbasic-1.0-linux64-790015a.tar.zst
	https://github.com/crow-misia/libwebrtc-bin/releases/download/114.5735.6.1/libwebrtc-linux-x64.tar.xz
	https://github.com/secondlife/llca/releases/download/v202407221723.0-a0fd5b9/llca-202407221423.0-common-10042698865.tar.zst
	http://automated-builds-secondlife-com.s3.amazonaws.com/ct2/4724/14846/llphysicsextensions_stub-1.0.504712-linux64-504712.tar.bz2
	https://github.com/zeux/meshoptimizer/archive/refs/tags/v0.21.tar.gz -> meshoptimizer-0.21.tar.gz
	https://github.com/secondlife/3p-mikktspace/releases/download/v2-e967e1b/mikktspace-1-linux64-8756084692.tar.zst
	https://github.com/secondlife/3p-open-libndofdev/releases/download/v1.14-r2/open_libndofdev-0.14.8730039102-linux64-8730039102.tar.zst
	https://github.com/uclouvain/openjpeg/archive/refs/tags/v2.5.3.tar.gz -> openjpeg-2.5.3.tar.gz
	https://github.com/secondlife/3p-openssl/releases/download/v1.1.1w-r1/openssl-1.1.1w-linux64-10329796904.tar.zst
	https://github.com/secondlife/3p-openxr/releases/download/v1.1.40-r1/openxr-1.1.40-r1-linux64-10710818432.tar.zst
	https://github.com/secondlife/3p-three_js/releases/download/v0.132.2-5da28d9/threejs-0.132.2-common-8454371083.tar.zst
	https://github.com/secondlife/3p-tinyexr/releases/download/v1.0.9-5e8947c/tinyexr-1.0.9-5e8947c-common-10475846787.tar.zst
	https://github.com/secondlife/3p-tinygltf/releases/download/v2.9.3-r1/tinygltf-2.9.3-r1-common-10341018043.tar.zst
	https://github.com/secondlife/3p-viewer-fonts/releases/download/v1.1.0-r1/viewer_fonts-1.0.0.10204976553-common-10204976553.tar.zst
"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"
IUSE="discord"

RDEPEND="
	media-libs/freealut
	dev-libs/apr-util
	dev-libs/boost[context]
	x11-libs/fltk
	app-text/hunspell
	net-libs/nghttp2
	media-libs/openjpeg
	media-libs/libsdl2[opengl]
	media-video/vlc
	sys-libs/zlib[minizip]
	app-accessibility/at-spi2-core
"
DEPEND="
	${RDEPEND}
	media-libs/glm
	media-libs/nanosvg
	media-video/pipewire
	media-libs/libpulse
	dev-libs/xxhash
"
BDEPEND="
	dev-build/cmake
	dev-util/pkgconf
	app-arch/zstd
"
S="${WORKDIR}/viewer"

CMAKE_BUILD_TYPE="Release"

pkg_setup() {
	export LL_BUILD="-fPIC -DLL_LINUX=1"
	export revision="$(ver_cut 2- ${PR})"
}

src_unpack() {
	unpacker
	cd ${WORKDIR}
	mkdir -p viewer/indra_build/packages
	mv 3p-colladadom-2.3-r8 meshoptimizer-0.21 openjpeg-2.5.3 viewer/indra_build/
	mv LICENSES NOTICE VERSION autobuild-package.xml bin ca-bundle.crt dictionaries docs fonts include js llphysicsextensions lib meta mikktspace.txt resources xui viewer/indra_build/packages/
}

src_prepare() {
	eapply "${FILESDIR}"/${P}-discord_sdk.patch
	eapply_user
	cd ${WORKDIR}/viewer/indra_build/3p-colladadom-2.3-r8
	eapply ${S}/patches/collada-dom-v2.3-r8.patch
	cd ${S}/indra
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DADDRESS_SIZE:STRING=64
		-DUSE_OPENAL:BOOL=ON
		-DUSE_FMODSTUDIO:BOOL=OFF
		-DUSE_DISCORD:BOOL=$(usex discord)
		-DENABLE_MEDIA_PLUGINS:BOOL=ON
		-DLL_TESTS:BOOL=OFF
		-DNDOF:BOOL=ON
		-DROOT_PROJECT_NAME:STRING=Megapahit
		-DVIEWER_CHANNEL:STRING=Megapahit
		-DVIEWER_BINARY_NAME:STRING=${PN}
		-DBUILD_SHARED_LIBS:BOOL=OFF
		-DINSTALL:BOOL=ON
		-DPACKAGE:BOOL=OFF
	)
	cmake_src_configure
}
