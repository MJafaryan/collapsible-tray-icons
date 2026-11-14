name := 'cosmic-ext-applet-status-hub'
appid := 'io.github.marcelogomes90.cosmic-ext-applet-status-hub'

rootdir := ''
prefix := '/usr'

base-dir := absolute_path(clean(rootdir / prefix))
cargo-target-dir := env('CARGO_TARGET_DIR', 'target')

bin-src := cargo-target-dir / 'release' / name
bin-dst := base-dir / 'bin' / name
desktop-dst := base-dir / 'share' / 'applications' / appid + '.desktop'
metainfo-dst := base-dir / 'share' / 'metainfo' / appid + '.metainfo.xml'
icon-dst := base-dir / 'share' / 'icons' / 'hicolor' / 'scalable' / 'apps' / appid + '.svg'
symbolic-icon-dst := base-dir / 'share' / 'icons' / 'hicolor' / 'scalable' / 'apps' / appid + '-symbolic.svg'

user-base := env('XDG_DATA_HOME', env('HOME') / '.local' / 'share')
user-bin-dst := env('HOME') / '.local' / 'bin' / name
user-desktop-dst := user-base / 'applications' / appid + '.desktop'
user-metainfo-dst := user-base / 'metainfo' / appid + '.metainfo.xml'
user-icon-dst := user-base / 'icons' / 'hicolor' / 'scalable' / 'apps' / appid + '.svg'
user-symbolic-icon-dst := user-base / 'icons' / 'hicolor' / 'scalable' / 'apps' / appid + '-symbolic.svg'

flatpak-dir := 'flatpak' / appid
manifest := flatpak-dir / appid + '.json'
flatpak-build-dir := 'build' / 'flatpak'

# See the list of recipes
default:
    @just --list

# Clean the build files
[group: 'Development']
clean:
    cargo clean

# Build the project for testing and development
[group: 'Development']
build-debug *args:
    cargo build {{args}}

# Build project from source code
[group: 'Build']
build-release *args: (build-debug '--release' args)

# Check the project codes
[group: 'Development']
check *args:
    cargo clippy --all-targets --all-features {{args}} -- -D warnings

[group: 'Development']
fmt:
    cargo fmt --all

[group: 'Development']
fmt-check:
    cargo fmt --all -- --check

# Run the project test
[group: 'Development']
test *args:
    cargo test --features testkit {{args}}

# Validate the project codes
[group: 'Development']
validate:
    #!/usr/bin/env bash
    set -euo pipefail
    output="$(desktop-file-validate resources/{{appid}}.desktop || true)"
    output="$(printf '%s\n' "${output}" | grep -v 'unregistered value "COSMIC"' \
        | grep -v 'does not contain a registered main category' | grep -v '^$' || true)"
    if [ -n "${output}" ]; then printf '%s\n' "${output}"; exit 1; fi
    echo "desktop entry ok"
    appstreamcli validate --no-net resources/{{appid}}.metainfo.xml

[group: 'Development']
verify: fmt-check check test validate

# Run project for test and development
[group: 'Development']
run *args:
    cargo run --bin {{name}} {{args}}

# Run project for test and development
[group: 'Development']
run-dump *args:
    cargo run --bin {{name}}-dump {{args}}

# Run project for test and development
[group: 'Development']
run-fake-item *args:
    cargo run --features testkit --example publish_item -- {{args}}

# Build and install project from source code
[group: 'Build']
install: build-release
    install -Dm0755 {{bin-src}} {{bin-dst}}
    install -Dm0644 resources/{{appid}}.desktop {{desktop-dst}}
    install -Dm0644 resources/{{appid}}.metainfo.xml {{metainfo-dst}}
    install -Dm0644 resources/{{appid}}.svg {{icon-dst}}
    install -Dm0644 resources/{{appid}}-symbolic.svg {{symbolic-icon-dst}}

# Build project for debian-based distros
[group: 'Build']
build-deb:
    #!usr/bin/env bash

# Uninstall manual installed project
[group: 'Build']
uninstall:
    rm -f {{bin-dst}} {{desktop-dst}} {{metainfo-dst}} {{icon-dst}} {{symbolic-icon-dst}}

# Build and install project from source code just for current user
[group: 'Build']
install-user: build-release
    install -Dm0755 {{bin-src}} {{user-bin-dst}}
    install -Dm0644 resources/{{appid}}.metainfo.xml {{user-metainfo-dst}}
    install -Dm0644 resources/{{appid}}.svg {{user-icon-dst}}
    install -Dm0644 resources/{{appid}}-symbolic.svg {{user-symbolic-icon-dst}}
    mkdir -p "$(dirname {{user-desktop-dst}})"
    sed 's|^Exec=.*|Exec={{user-bin-dst}}|' resources/{{appid}}.desktop > {{user-desktop-dst}}
    chmod 0644 {{user-desktop-dst}}
    @echo "Installed. Add 'Status Hub' in Settings -> Desktop -> Panel -> Applets."

# Uninstall manual installed project just for current user
[group: 'Build']
uninstall-user:
    rm -f {{user-bin-dst}} {{user-desktop-dst}} {{user-metainfo-dst}} {{user-icon-dst}} {{user-symbolic-icon-dst}}
