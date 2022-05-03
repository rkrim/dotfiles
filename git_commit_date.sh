git filter-branch -f --env-filter '
COMMIT_HASH="a99f0639cf7d995f87bbd8da73a820c516db014b"
NEW_DATE="Sat May 28 23:26:11 2022 +0200"

if [ $GIT_COMMIT = "$COMMIT_HASH" ]
then
    export GIT_AUTHOR_DATE="$NEW_DATE"
    export GIT_COMMITTER_DATE="$NEW_DATE"
fi
'
