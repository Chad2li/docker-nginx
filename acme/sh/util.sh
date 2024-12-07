#!/bin/bash

# 切分
split() {
  old_ifs=$IFS
  IFS="$2" read -r -a _split_arr <<< "$1"
  IFS=$old_ifs
}

# 拼接
# arg-1: 拼接符, 后续为值
join() {
  index=0
  join_str=''
  for i in "$@"
  do
    if [ $index -gt 0 ]; then
      join_str=$join_str$1$i
    fi
    index=$((index+1))
  done
}