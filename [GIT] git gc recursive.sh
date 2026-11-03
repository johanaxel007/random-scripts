#!/bin/bash
#source: https://gist.github.com/nvk/5404237?permalink_comment_id=820051#gistcomment-820051

find -name .git -execdir git gc --aggressive ";"
