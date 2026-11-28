#!/usr/bin/env bash
# Build and install "Sarasa Mono SC Nerd" for the Herdr app.
#
# Why: herdr-app (GPUI + cosmic-text) has no per-glyph font fallback, so a
# terminal font without CJK draws Chinese/Japanese/Korean as blank cells.
# Sarasa Mono carries Iosevka's Latin letterforms plus Source Han Sans CJK, and
# this script merges the Nerd Font icon glyphs from the installed Iosevka Nerd
# Font into it, so one family covers Latin + CJK + icons.
#
# Note: Sarasa "Mono" is the Iosevka-based variant; plain "Sarasa Gothic" uses Inter.
#
# The merged font drops CJK Ext-B (rare non-BMP ideographs) to stay under the
# 65535-glyph TrueType limit: Sarasa is ~57k glyphs and the icon set is ~10k.
#
# Usage: ./install-herdr-font.sh [--force]
set -e -o pipefail

sarasa_version="1.0.44"
family="Sarasa Mono SC Nerd"
asset="SarasaMonoSC-TTF-Unhinted-${sarasa_version}.7z"
url="https://github.com/be5invis/Sarasa-Gothic/releases/download/v${sarasa_version}/${asset}"
# Bump when the build inputs change so an existing install is rebuilt.
build_id="sarasa-${sarasa_version}-nerd-icons-1"
weights="Regular Bold"
font_dir="$HOME/.local/share/fonts/sarasa-nerd"
work=""

force=""
case "${1:-}" in
--force) force="1" ;;
"") ;;
*)
	echo "Usage: $0 [--force]" >&2
	exit 1
	;;
esac

cleanup() {
	[[ -n "$work" ]] && rm -rf "$work"
}
trap cleanup EXIT

if [[ -z "$force" && -f "$font_dir/.build" ]] && [[ "$(cat "$font_dir/.build")" == "$build_id" ]]; then
	echo "------------------------------------------"
	echo "$family already installed ($build_id). Use --force to rebuild."
	echo "------------------------------------------"
	exit 0
fi

echo "------------------------------------------"
echo "Installing $family"
echo "------------------------------------------"

for tool in curl 7z python3 fc-cache; do
	command -v "$tool" >/dev/null || {
		echo "Missing required tool: $tool" >&2
		case "$tool" in
		7z) echo "Install it with: sudo apt install p7zip-full" >&2 ;;
		fc-cache) echo "Install it with: sudo apt install fontconfig" >&2 ;;
		esac
		exit 1
	}
done

# Icons come from an installed Iosevka Nerd Font (ubuntu-install.sh puts one in
# ~/.fonts); fetch the official build when the machine has none.
work="$(mktemp -d)"
nerd_fonts_version="3.5.1"
nerd_dir="$HOME/.fonts"

icon_source_for() {
	local weight="$1" style="Regular" candidate
	[[ "$weight" == "Bold" ]] && style="Bold"
	for candidate in \
		"$nerd_dir/IosevkaNerdFont-${weight}.ttf" \
		"$HOME/.local/share/fonts/IosevkaNerdFont-${weight}.ttf" \
		"$(fc-match -f '%{file}' "Iosevka Nerd Font:style=${style}" 2>/dev/null)"; do
		[[ -f "$candidate" ]] && {
			printf '%s\n' "$candidate"
			return 0
		}
	done
	return 1
}

if ! icon_source_for Regular >/dev/null || ! icon_source_for Bold >/dev/null; then
	echo "Iosevka Nerd Font is not installed; fetching it for the icon glyphs (~30MB)"
	curl -fL --retry 3 -o "$work/nerd.tar.xz" \
		"https://github.com/ryanoasis/nerd-fonts/releases/download/v${nerd_fonts_version}/Iosevka.tar.xz"
	mkdir -p "$work/nerd"
	tar -xJf "$work/nerd.tar.xz" -C "$work/nerd" IosevkaNerdFont-Regular.ttf IosevkaNerdFont-Bold.ttf
	nerd_dir="$work/nerd"
fi

declare -A icon_sources=()
for weight in $weights; do
	icon_sources[$weight]="$(icon_source_for "$weight")" || {
		echo "No Iosevka Nerd Font ($weight) available for the icon glyphs" >&2
		exit 1
	}
done


# fontTools is only needed at build time; keep it out of the system python.
python_cmd=(python3)
if ! python3 -c 'import fontTools' >/dev/null 2>&1; then
	echo "Setting up a temporary fontTools environment"
	python3 -m venv "$work/python" >/dev/null 2>&1 || {
		echo "Could not create a python venv; install python3-venv" >&2
		exit 1
	}
	"$work/python/bin/pip" -q install fonttools
	python_cmd=("$work/python/bin/python")
fi

echo "Downloading $asset (~49MB)"
curl -fL --retry 3 -o "$work/sarasa.7z" "$url"
7z e -y "$work/sarasa.7z" -o"$work/src" 'SarasaMonoSC-*.ttf' >/dev/null

cat >"$work/patch_nerd.py" <<'PY'
"""Merge Nerd Font icon glyphs into Sarasa Mono SC and rename the family.

Copies every codepoint the target font lacks, so the icon ranges arrive with
their real outlines. Pure fontTools: no fontforge needed.
"""

import sys

from fontTools.pens.recordingPen import DecomposingRecordingPen
from fontTools.pens.ttGlyphPen import TTGlyphPen
from fontTools.ttLib import TTFont

dst_path, src_path, out_path, new_family = sys.argv[1:5]

dst = TTFont(dst_path)
src = TTFont(src_path)

scale = dst["head"].unitsPerEm / src["head"].unitsPerEm
dst_cmap = dst.getBestCmap()
src_cmap = src.getBestCmap()
missing = {cp: glyph for cp, glyph in src_cmap.items() if cp not in dst_cmap}

src_glyphset = src.getGlyphSet()
src_hmtx = src["hmtx"].metrics
glyf, hmtx = dst["glyf"], dst["hmtx"].metrics
order = dst.getGlyphOrder()
taken = set(order)

added = {}
for cp, glyph_name in sorted(missing.items()):
    new_name = glyph_name
    while new_name in taken:
        new_name += ".nf"
    try:
        recording = DecomposingRecordingPen(src_glyphset)
        src_glyphset[glyph_name].draw(recording)
        pen = TTGlyphPen(None)
        recording.replay(pen)
        glyph = pen.glyph()
    except Exception as exc:  # malformed or empty outlines
        print(f"skip U+{cp:04X} {glyph_name}: {exc}", file=sys.stderr)
        continue
    glyf.glyphs[new_name] = glyph
    advance = int(round(src_hmtx[glyph_name][0] * scale))
    hmtx[new_name] = (advance, getattr(glyph, "xMin", 0))
    taken.add(new_name)
    added[cp] = new_name

dst.setGlyphOrder(order + list(added.values()))

for table in dst["cmap"].tables:
    if not table.isUnicode():
        continue
    for cp, new_name in added.items():
        if (table.format == 4 and cp <= 0xFFFF) or table.format == 12:
            table.cmap[cp] = new_name

# The BMP-only subset prunes the format-12 subtable; rebuild it so the non-BMP
# icon codepoints (U+F0001 and up) stay reachable.
if any(cp > 0xFFFF for cp in added) and not any(
    table.isUnicode() and table.format == 12 for table in dst["cmap"].tables
):
    from fontTools.ttLib.tables._c_m_a_p import CmapSubtable

    cmap = dict(dst["cmap"].getBestCmap())
    cmap.update(added)
    subtable = CmapSubtable.newSubtable(12)
    subtable.platformID, subtable.platEncID, subtable.language = 3, 10, 0
    subtable.cmap = cmap
    dst["cmap"].tables.append(subtable)

# Device/hinting tables would now describe glyphs that no longer match.
for tag in ("VDMX", "hdmx", "LTSH"):
    if tag in dst:
        del dst[tag]

postscript_family = new_family.replace(" ", "")
for rec in dst["name"].names:
    if rec.nameID in (1, 4, 16):
        rec.string = new_family
    elif rec.nameID in (3, 6):
        rec.string = (
            rec.toUnicode()
            .replace("SarasaMonoSC", postscript_family)
            .replace("Sarasa Mono SC", postscript_family)
        )

dst.save(out_path)
print(f"{out_path}: +{len(added)} glyphs as '{new_family}'")
PY

for weight in $weights; do
	echo "Building $weight"
	# BMP only: keeps the merged font under the 65535-glyph TrueType limit.
	"${python_cmd[@]}" -m fontTools.subset "$work/src/SarasaMonoSC-${weight}.ttf" \
		--unicodes='U+0000-FFFF' \
		--layout-features='*' \
		--name-IDs='*' \
		--output-file="$work/bmp-${weight}.ttf"
	"${python_cmd[@]}" "$work/patch_nerd.py" \
		"$work/bmp-${weight}.ttf" \
		"${icon_sources[$weight]}" \
		"$work/$family-$weight.ttf" \
		"$family"
done

echo "Installing into $font_dir"
mkdir -p "$font_dir"
for weight in $weights; do
	install -m 644 "$work/$family-$weight.ttf" "$font_dir/${family// /}-$weight.ttf"
done
printf '%s' "$build_id" >"$font_dir/.build"
fc-cache -f >/dev/null

echo "Verifying"
installed="$(fc-list "$family" | wc -l)"
[[ "$installed" -ge 2 ]] || {
	echo "$family not visible to fontconfig after install" >&2
	exit 1
}
"${python_cmd[@]}" - "$font_dir/${family// /}-Regular.ttf" <<'PY'
import sys

from fontTools.ttLib import TTFont

cmap = TTFont(sys.argv[1]).getBestCmap()
missing = [hex(cp) for cp in (0x4E2D, 0x3042, 0xD55C, 0xE0B0, 0xF0001) if cp not in cmap]
if missing:
    sys.exit(f"missing codepoints in built font: {', '.join(missing)}")
PY

echo "------------------------------------------"
echo "$family installed ($installed files)"
echo "Set in ~/.config/herdr-app/settings.json:"
echo "  \"font\": \"$family\","
echo "  \"ui_font\": \"$family\""
echo "Restart herdr-app, or nudge font_size, so panes re-shape with the new font."
echo "------------------------------------------"
