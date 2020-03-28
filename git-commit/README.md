# bidrag-actions/git-commit

This action will commit changed repository files and push to origin

Requires a runner with node and ncc installed. Also the running environment must be able to execute
bash scripts.

The action requires the commit message. An optional input is a file with content to add to the commit
message.

If a file containing some commit message content is present, the content will replace {} from the commit
message provided.

The author information of the commit will be gathered from the GITHUB_EVENT. If no event is present, the
following information will be used:
- Author name: Tag & Commit Action
- Author email: navikt.bidrag-actions.git-commit@github.com
