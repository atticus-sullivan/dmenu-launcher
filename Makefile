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
	f="$$(find . -iname "dmenu-launcher-dev-[a-f0-9.]*-x86_64.pkg.tar.zst" | grep -v "debug" | sort | tail -n1)" && sudo pacman -U "$$f"

install-release: pkg-release
	f="$$(find . -iname "dmenu-launcher-[0-9.]*-x86_64.pkg.tar.zst" | grep -v "debug" | sort | tail -n1)" && sudo pacman -U "$$f"

pkg: pkg-dev

pkg-release:
	makepkg -D pkg-release -c
	mv pkg-release/*.tar.zst .
	curl -X PUT https://git.atticus-sullivan.de/api/packages/wm-tools/arch/extras/ --user lukas:$$(secret-tool lookup name "git.atticus-sullivan.de pkg-upload") --header "Content-Type: application/octet-stream" --data-binary "@$$(readlink -f $$(find . -iname 'dmenu-launcher-[0-9.]*-x86_64.pkg.tar.zst' | grep -v 'debug' | sort | tail -n1))"

pkg-dev:
	makepkg -D pkg-dev -c
	mv pkg-dev/*.tar.zst .

clean:
	-$(RM) *.tar.gz *.tar.zst
