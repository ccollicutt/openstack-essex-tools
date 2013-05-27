#!/bin/bash


#
# Vars
# 

USED_IMAGES=$(mktemp)
ALL_IMAGES=$(mktemp)
REMOVE_IMAGES=$(mktemp)
INSTANCES_DIR="/var/lib/nova/instances"

#
# Drop all used images into a file
#
#pushd $INSTANCES_DIR > /dev/null 
find $INSTANCES_DIR -name "disk*" | \
	xargs -n1 qemu-img info | \
	grep backing | \
	sed -e's/.*file: //' -e 's/ .*//' | \
	sort | \
	uniq > $USED_IMAGES
#popd > /dev/null

#
# Create a file that has all images in it
# 
find $INSTANCES_DIR/_base/* | \
	grep -v ephemeral > $ALL_IMAGES

#
# Find out what lines are in $ALL_IMAGES that are NOT in $USED_IMAGES
# ie. lines unique to file 2, which is ALL_IMAGES
# So this will print images in $INSTANCES_DIR that could be removed.
comm -13 <(sort $USED_IMAGES) <(sort $ALL_IMAGES) > $REMOVE_IMAGES

NUM_USED_IMAGES=$(wc -l $USED_IMAGES)
NUM_ALL_IMAGES=$(wc -l $ALL_IMAGES)
NUM_REMOVE_IMAGES=$(wc -l $REMOVE_IMAGES)
#echo "== $NUM_USED_IMAGES IMAGES IN USE =============="
#cat $USED_IMAGES

#echo "== $NUM_ALL_IMAGES TOTAL IMAGES =============="
#cat $ALL_IMAGES

#echo "== $NUM_REMOVE_IMAGES IMAGES TO REMOVE ============="
cat $REMOVE_IMAGES

#
# Cleanup
# 
#echo "USED_IMAGES is $USED_IMAGES"
#echo "ALL_IMAGES is $ALL_IMAGES"
rm $USED_IMAGES
rm $ALL_IMAGES
rm $REMOVE_IMAGES
