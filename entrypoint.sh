#!/usr/bin/env bash

cd "$GITHUB_WORKSPACE" || exit 1

# initialize exit code
exit_code=0
openmp=$(echo | cpp -fopenmp -dM | grep -i open)
binary=./mcmap
savefile=/benchmark
timelog=time.log
images=images

compilation=$(make)

if [[ "$?" -ne 0 ]]; then
    echo "Build failed:"
    echo "$compilation"
    exit 1
fi

echo -n > $timelog
mkdir -p $images

tests=(
    "-from -16 -16 -to 15 15 -nw"
    "-from -16 -16 -to 15 15 -sw"
    "-from -16 -16 -to 15 15 -se"
    "-from -16 -16 -to 15 15 -ne"
    "-from -16 -16 -to 15 15 -min 16"
    "-from -16 -16 -to 15 15 -max 63"
    "-from -64 -64 -to 63 63 -nether"
    "-from -64 -64 -to 63 63 -end"
    "-from -64 -64 -to 63 63 -nowater"
    "-from -64 -64 -to 63 63 -colors /colors.json"
    "-from 0 0 -to 511 511"
    "-from 0 0 -to 63 63 -splits 4"
    "-from 0 0 -to 15 15 -padding 0"
    "-from 0 0 -to 15 15 -padding 48"
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
