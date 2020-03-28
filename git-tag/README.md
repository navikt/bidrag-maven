# bidrag-actions/git-tag

This action will tag a git repository on current HEAD commit

Requires a runner with node and ncc installed. Also the running environment must be able to execute
bash scripts.

The action requires a file with the tag and the message for the tag.

The tag file containing will replace {} in the tag message (if exists).

The author information of the commit will be gathered from the GITHUB_EVENT. If no event is present, the
following information will be used:
- Author name: Tag & Commit Action
- Author email: navikt.bidrag-actions.git-commit@github.com
