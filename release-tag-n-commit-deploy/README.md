# bidrag-actions/tag-and-commit-mvn-deploy

This action is strongly coupled with `release-prepare-mvn-pkg` and `release-verify-auto-deploy` and
will create a tag, commit changed repository files, and push this to origin (when `is_release_candidate`)

Requires a runner with node and ncc installed. Also the running environment must be able to execute
bash scripts.

The action requires a the tag to push, the message of the commit and tag, the
pattern to use with git add, and a file explaining it it is an automatic release; see action.yml.

If a file containing the content of a tag is present, the content will replace {} from the commit
message and for the tag message (if provided).

The author information of the tag and commit will be gathered from the GITHUB_EVENT. If no event is
present, the following information will be used:
- Author name: Tag & Commit Action
- Author email: navikt.bidrag-actions.git-tag-n-commit@github.com
