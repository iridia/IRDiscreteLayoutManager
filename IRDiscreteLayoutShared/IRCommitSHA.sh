#!/bin/sh

#  IRCommitSHA.sh
#  IRDiscreteLayoutManager
#
#  Created by Evadne Wu on 8/29/11.
#  Copyright 2011 Iridia Productions. All rights reserved.

echo "TARGET_BUILD_DIR $TARGET_BUILD_DIR"
echo "INFOPLIST_PATH $INFOPLIST_PATH"

commitSha=$(git rev-parse HEAD | head -c 7)
infoPlistPath="$TARGET_BUILD_DIR/$INFOPLIST_PATH"

/usr/libexec/PlistBuddy -c "Delete :IRCommitSHA" $infoPlistPath
/usr/libexec/PlistBuddy -c "Add :IRCommitSHA string $commitSha" $infoPlistPath
