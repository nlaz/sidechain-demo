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
VOCALS_AUDIO="$2"
OUTPUT_AUDIO="output_$(basename "$MAIN_AUDIO")"

# Compression parameters
THRESHOLD=0.02
RATIO=4
ATTACK=20
RELEASE=300

MAIN_DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$MAIN_AUDIO")
echo "Duration of main audio: $MAIN_DURATION"
echo "\n"

# Construct the FFmpeg command
FFMPEG_CMD="ffmpeg -i \"$MAIN_AUDIO\" -i \"$VOCALS_AUDIO\" \
    -filter_complex \"
    [1:a]adelay=3000|3000[delayed_vocals];
    [delayed_vocals]apad=whole_dur=$MAIN_DURATION[padded_vocals];
    [padded_vocals]asplit=2[vocals_for_sidechain][vocals_for_mix];
    [0:a][vocals_for_sidechain]sidechaincompress=threshold=$THRESHOLD:ratio=$RATIO:attack=$ATTACK:release=$RELEASE[compressed_main];
    [compressed_main][vocals_for_mix]amix=inputs=2:duration=longest[final_mix]
    \" \
    -map \"[final_mix]\" \"$OUTPUT_AUDIO\""

# Echo the command to the terminal
echo "Executing FFmpeg command:"
echo "$FFMPEG_CMD"

# Run FFmpeg command
eval "$FFMPEG_CMD"

echo "Sidechain compression complete. Output saved as $OUTPUT_AUDIO"