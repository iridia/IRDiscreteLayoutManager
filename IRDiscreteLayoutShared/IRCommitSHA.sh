#!/bin/sh

#  IRCommitSHA.sh
#  IRDiscreteLayoutManager
#
#  Created by Evadne Wu on 8/29/11.
#  Copyright 2011 Iridia Productions. All rights reserved.

commitSha=$(git rev-parse HEAD | head -c 7)
infoPlistPath=$TARGET_BUILD_DIR/$INFOPLIST_PATH

/usr/libexec/PlistBuddy -c "Delete :IRCommitSHA" $infoPlistPath
/usr/libexec/PlistBuddy -c "Add :IRCommitSHA string $commitSha" $infoPlistPath
