#!/usr/bin/env bash

cd "$GITHUB_WORKSPACE" || exit 1

# initialize exit code
exit_code=0
binary=./mcmap
savefile=/benchmark
timelog=time.log
images=images

compilation=$(cmake . && make)

if [[ "$?" -ne 0 ]]; then
    echo "Build failed:"
    echo "$compilation"
    exit 1
fi

echo -n > $timelog
mkdir -p $images

tests=(
    ""
    "-from 0 0 -to 511 511"
    "-nw"
    "-sw"
    "-se"
    "-ne"
    "-min 16"
    "-max 63"
    "-nether"
    "-end"
    "-nowater"
    "-nobeacons"
    "-colors /colors.json"
    "-tile 32"
    "-tile 64"
    "-tile 128"
    "-tile 256"
    "-tile 512"
    "-from 0 0 -to 15 15 -padding 0"
    "-from 0 0 -to 15 15 -padding 48"
    "-marker 0 0 red -marker 511 511 green"
    "-shading"
)

index=0
for options in "${tests[@]}"; do
    echo -n "Running with $options .. "
    output=$( { time -p $binary $savefile $options -file $images/map-$index.png; } 2>&1 )

    if [[ "$?" -ne 0 ]]; then
        echo "Image generation error: $options"
        echo "$output"
        exit_code=1
        echo "FAILED: $options" >> $timelog
    else
        echo "$output" | grep real | cut -f2 -d' ' >> $timelog
        echo "done in $(tail -n1 $timelog)s"
    fi

    index=$((index + 1))
done

tar -cvzf images.tgz $images 
exit "$exit_code"
