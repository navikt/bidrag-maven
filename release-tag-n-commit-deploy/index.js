const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  try {

    setAuthorInformation();

    const commitMessage = core.getInput('commit_message');
    const tagMessage = core.getInput('tag_message');
    const pattern = core.getInput('pattern');
    const isReleaseCandidate = core.getInput('is_release_candidate');
    const tag = core.getInput('tag');

    await exec.exec(
        `bash ${__dirname}/release-tag-n-commit.sh "${commitMessage}" "${tagMessage}" ${pattern} ${isReleaseCandidate} ${tag}`
    );

  } catch (error) {
    core.setFailed(error.message);
  }
}

function setAuthorInformation() {
  const eventPath = process.env.GITHUB_EVENT_PATH;

  if (eventPath) {
    const {author} = require(eventPath).head_commit;

    process.env.AUTHOR_NAME = author.name;
    process.env.AUTHOR_EMAIL = author.email;

  } else {
    core.warning('No event path available, unable to fetch author info.');

    process.env.AUTHOR_NAME = 'Tag & Commit Action';
    process.env.AUTHOR_EMAIL = 'navikt.bidrag-actions.git-tag-n-commit@github.com';
  }

  core.info(
      `Using '${process.env.AUTHOR_NAME} <${process.env.AUTHOR_EMAIL}>' as author.`
  );
}

// noinspection JSIgnoredPromiseFromCall
run();
