#!/bin/sh

set -eu

source_version=2.100
font_version=2.100
archive=fonts/GenYoGothic2-ttc.zip
archive_checksum=770cff05d612a400f9cc27bb11998d73225d80669bf23d6423545252178a7ffe

# Download source

mkdir -p fonts
if [ ! -f "$archive" ]; then
    curl --fail --location --retry 3 --output "$archive" "https://github.com/ButTaiwan/genyog-font/releases/download/v$source_version/GenYoGothic2-ttc.zip"
fi
actual_checksum=$(shasum -a 256 "$archive" | cut -d ' ' -f 1)
if [ "$actual_checksum" != "$archive_checksum" ]; then
    echo "Checksum mismatch for $archive" >&2
    exit 1
fi
unzip -o "$archive" '*.ttc' -d fonts

# Generate fonts

mkdir -p output
for input_file in fonts/GenYoGothic2-*.ttc; do
    style=${input_file#fonts/GenYoGothic2-}
    style=${style%.ttc}
    output_file="output/FanWunHak-$style.ttf"
    output_file_twp="output/FanWunHak-TW-$style.ttf"

    python3 -m OpenCCFontGenerator -i "$input_file" -o "$output_file" -n config/name.json --ttc-index 0 --font-version "$font_version"
    python3 -m OpenCCFontGenerator -i "$input_file" -o "$output_file_twp" -n config/name-twp.json --ttc-index 0 --font-version "$font_version" --twp
done
