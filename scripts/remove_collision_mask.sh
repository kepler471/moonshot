#!/bin/bash

# removes a layer which just has baddies
SEARCH_STRING="collision_mask = 5"

function remove_collision_mask {
    for file in $(ls $dir)
    do
        if [[ "$file" == *tscn ]]; then
            echo "removing collision mask for ::: '$file' ";
            sed -i '' 's/collision_mask = 5//g' $file
        else
            echo "not a correct file";
        fi
    done
}
