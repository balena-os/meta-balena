#!/usr/bin/env bash
#
# Build the CRC gate modules and the B-6 measurement.
# Inputs: /in/base.tar.gz and /in/ext.tar.gz, kernel_modules_headers archives.
# Outputs in /out: control.ko, subject.ko, base.ko and measure.env.

set -euo pipefail

readonly in=/in
readonly out=/out
readonly src=/src
readonly work=/work

fail() {
	echo "build.sh: $*" >&2
	exit 1
}

extract() {
	local tarball="$1" dest="$2" depth
	# Strip leading path to the directory holding .config.
	depth=$(tar tf "$tarball" | grep '/\.config$' | tr -dc / | wc -c)
	mkdir -p "$dest"
	tar -xf "$tarball" -C "$dest" --strip-components "$depth"
}

build() {
	local tree="$1" name="$2" dir="$work/build-$2"
	mkdir -p "$dir"
	cp "$src"/* "$dir"/
	make -C "$work/$tree" M="$dir" modules
	cp "$dir/crc_gate.ko" "$out/$name.ko"
}

crcs() {
	awk '{ print $2" "$1 }' "$work/$1/Module.symvers" | LC_ALL=C sort -u
}

moved() {
	LC_ALL=C join <(crcs base) <(crcs ext) | awk '$2 != $3'
}

# Symbols with a CRC recorded in the __versions table.
referenced() {
	gawk 'match($0, /\{ *0x[0-9a-f]+, *"([^"]+)" *\}/, m) { print m[1] }' \
		"$work/build-base/crc_gate.mod.c" | LC_ALL=C sort -u
}

main() {
	local jobs changed referenced_count moved_total moved_referenced
	jobs=$(nproc)
	mkdir -p "$work" "$out"

	extract "$in/base.tar.gz" "$work/base"
	extract "$in/ext.tar.gz" "$work/ext"
	make -C "$work/base" -j "$jobs" modules_prepare
	make -C "$work/ext" -j "$jobs" modules_prepare

	cp -a "$work/ext" "$work/subject"
	# Tab FS keeps the empty namespace field modpost requires.
	gawk 'BEGIN { FS = OFS = "\t" }
		$2 == "_printk" { $1 = sprintf("0x%08x", xor(strtonum($1), 1)) } 1' \
		"$work/ext/Module.symvers" > "$work/subject/Module.symvers"
	changed=$({ diff -U0 "$work/ext/Module.symvers" "$work/subject/Module.symvers" || true; } \
		| grep -c '^+[^+]' || true)
	[ "$changed" = 1 ] || fail "expected 1 changed line in subject Module.symvers, got $changed"

	build ext control
	build subject subject
	build base base

	referenced_count=$(referenced | wc -l)
	if grep -q '^CONFIG_MODVERSIONS=y' "$work/base/.config" && [ "$referenced_count" = 0 ]; then
		fail "no __versions entries in crc_gate.mod.c; unknown modversions format"
	fi

	# Plain assignments, so a failed pipeline stops the script.
	moved_total=$(moved | wc -l)
	moved_referenced=$(LC_ALL=C join <(referenced) <(moved) | wc -l)
	printf 'MOVED_TOTAL=%s\nMOVED_REFERENCED=%s\n' "$moved_total" "$moved_referenced" \
		> "$out/measure.env"
	cat "$out/measure.env"
}

main "$@"
