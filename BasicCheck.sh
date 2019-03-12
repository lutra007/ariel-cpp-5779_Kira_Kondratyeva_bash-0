#!/bin/bash

my_dir=$1
my_compile=$2

args=''
while [ "$3" != "" ]; do
    args="$args $3"
    shift
done

comp='FAIL'
memory='FAIL'
race='FAIL'

if [ -e $my_dir/Makefile ]
then
    #echo "make -C $my_dir &> /dev/null 2>&1"
    make -C $my_dir &> /dev/null 2>&1
    retval=$?
else
    printf "Compilation        Memory leaks        thread race\n    %s               %s               %s\n" "$comp" "$memory" "$race"
    exit 7
fi

if [ $retval -eq 0 ] && [ -e $my_dir/$my_compile ]
then
    comp='PASS'
    #valgrind --leak-check=full --error-exitcode=1 $my_dir/$my_compile $args 2>&1
    valgrind --leak-check=full --error-exitcode=1 $my_dir/$my_compile $args &> /dev/null 2>&1
    lick=$?
    #valgrind --tool=helgrind --error-exitcode=1 $my_dir/$my_compile $args 2>&1
    valgrind --tool=helgrind --error-exitcode=1 $my_dir/$my_compile $args &> /dev/null 2>&1
    threads=$?
    
    #echo lick $lick
    #echo threads $threads    
    #rm $my_compile
else
    printf "Compilation        Memory leaks        thread race\n    %s               %s               %s\n" "$comp" "$memory" "$race"
    exit 7
fi

if [ $lick -eq 0 ]; then
    memory='PASS'
else
    lick=2
fi

if [ $threads -eq 0 ]; then
    race='PASS'
else
    threads=1
fi

ans=$((lick + threads))

printf "Compilation        Memory leaks        thread race\n    %s               %s               %s\n" "$comp" "$memory" "$race"
exit $ans
