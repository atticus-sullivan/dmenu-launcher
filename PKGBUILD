# Maintainer: Lukas Heindl <oss.heindl@protonmail.com>
pkgname=dmenu-launcher
pkgver=0.9.0
pkgrel=1
pkgdesc="A simple app launcher using dmenu"
arch=('x86_64')
url="https://github.com/atticus-sullivan/dmenu-launcher"
license=('MIT')
makedepends=('git' 'cargo')
optdepends=('dmenu: can also be installed manually')
source=("dmenu-launcher-${pkgver}.tar.gz::${url}/archive/refs/tags/${pkgver}.tar.gz")
sha256sums=('SKIP')

prepare() {
	cd "dmenu-launcher-${pkgver}"
	export RUSTUP_TOOLCHAIN=stable
	cargo fetch --locked --target "$(rustc -vV | sed -n 's/host: //p')"
}

build() {
	cd "dmenu-launcher-${pkgver}"

	export RUSTUP_TOOLCHAIN=stable
	export CARGO_TARGET_DIR=target

	cargo build --frozen --release --all-features
}

check() {
	export RUSTUP_TOOLCHAIN=stable
	cargo test --frozen --all-features
}

package() {
	cd "dmenu-launcher-${pkgver}"
	install -Dm755 "target/release/dmenu-launcher-utils" "$pkgdir/usr/local/bin/dmenu-launcher-utils"
	install -Dm755 "dmenu-launcher.bash"                 "$pkgdir/usr/local/bin/dmenu-launcher"
	install -Dm755 "config.yml"                          "$pkgdir/usr/local/etc/dmenu-launcher.yml"
}
