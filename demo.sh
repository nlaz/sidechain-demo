#!/bin/bash

# Check if FFmpeg is installed
if ! command -v ffmpeg &> /dev/null
then
    echo "FFmpeg is not installed. Please install it and try again."
    exit 1
fi

# Input validation
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <main_audio_file> <sidechain_audio_file>"
    exit 1
fi

# Set variables
MAIN_AUDIO="$1"
SIDECHAIN_AUDIO="$2"
OUTPUT_AUDIO="output_$(basename "$MAIN_AUDIO")"

# Compression parameters
THRESHOLD=0.01
RATIO=20
ATTACK=5
RELEASE=300

# Run FFmpeg command
ffmpeg -re -i "$MAIN_AUDIO" -i "$SIDECHAIN_AUDIO" \
-filter_complex "\
[1:a]asplit=2[sc][mix]; \
[0:a][sc]sidechaincompress=threshold=$THRESHOLD:ratio=$RATIO:attack=$ATTACK:release=$RELEASE[compressed]; \
[compressed][mix]amix=weights=1 1" \
"$OUTPUT_AUDIO"

echo "Sidechain compression complete. Output saved as $OUTPUT_AUDIO"