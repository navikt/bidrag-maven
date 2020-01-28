# bidrag-actions/tag-and-commit

This action will create a tag, commit changed repository files, and push to origin

Requires a runner with node and ncc installed. Also the running environment must be able to execute
bash scripts.

The action requires a file containing the tag to push, the message of the commit and tag, the
pattern to use with git add, and a file explaining it it is an automatic release; see action.yml.

If a file containing the content of a tag is present, the content will replace {} from the commit
message and for the tag message (if provided).

The author information of the tag and commit should be gathered from the GITHUB_EVENT, ie:
${{ github.head_commit.author }}
