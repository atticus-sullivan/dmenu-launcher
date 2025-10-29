.PHONY: all run build buildAll buildRelease run check contCheck cont test install pkg clean pkg-dev pkg-release install-dev install-release

SRC_FILES = $(shell find src/ -iname "*.rs")

all: run
	

test:
	cargo test

target/release/dmenu-launcher: $(SRC_FILES)
	RUSTC_WRAPPER=sccache cargo build --release

target/debug/dmenu-launcher: $(SRC_FILES)
	RUSTC_WRAPPER=sccache cargo build

buildAll: buildRelease build
	

build: target/debug/dmenu-launcher
	

buildRelease: target/release/dmenu-launcher
	

run:
	RUSTC_WRAPPER=sccache cargo run

check:
	RUSTC_WRAPPER=sccache cargo check

contCheck:
	luamon -l rust -e rs -w . -t -x make -- check

cont:
	luamon -l rust -e rs -w . -t -x make

coverage:
	$(RM) target/profraw/*
	$(RM) -r target/coverage/*
	RUSTFLAGS='-Cinstrument-coverage' LLVM_PROFILE_FILE='target/profraw/cargo-test-%p-%m.profraw' cargo test
	grcov target/profraw/ --binary-path ./target/debug/deps/ -s . -t html --branch --ignore-not-existing --ignore '../*' --ignore "/*" -o target/coverage

install: install-dev

install-dev: pkg-dev
	f="$$(find . -iname "dmenu-launcher-[a-f0-9.]*-x86_64.pkg.tar.zst" | grep -v "debug" | head -n 1)" && sudo pacman -U "$$f"

install-release: pkg-release
	f="$$(find . -iname "dmenu-launcher-dev-[0-9.]*-x86_64.pkg.tar.zst" | grep -v "debug" | head -n 1)" && sudo pacman -U "$$f"

pkg: pkg-dev

pkg-release:
	makepkg -D build-release -c
	mv build-release/*.tar.zst .

pkg-dev:
	makepkg -D build-dev -c
	mv build-dev/*.tar.zst .

clean:
	-$(RM) *.tar.gz *.tar.zst
