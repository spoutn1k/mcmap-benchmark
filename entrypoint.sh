#!/usr/bin/env bash

cd "$GITHUB_WORKSPACE" || exit 1

# initialize exit code
exit_code=0

compilation=$(make)

if [[ "$?" -ne 0 ]]; then
    echo "Build failed:"
    echo "$compilation"
    exit 1
fi

output=$( { time -p ./mcmap -from 0 0 -to 511 511 benchmark; } 2>&1 )

if [[ "$?" -ne 0 ]]; then
    echo "Image generation error:"
    echo "$output"
    exit 1
fi

echo "$output" | grep real | cut -f2 -d' ' > bench_time
echo "Generated image in $(cat bench_time)s"

exit "$exit_code"
