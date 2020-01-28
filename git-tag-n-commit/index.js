const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  try {

    setAuthorInformation();

    // Execute tag bash script
    await exec.exec(`${__dirname}/git.sh`);

  } catch (error) {
    core.setFailed(error.message);
  }
}

function setAuthorInformation() {
  const eventPath = process.env.GITHUB_EVENT_PATH;

  if (eventPath) {
    const { author } = require(eventPath).head_commit;

    process.env.AUTHOR_NAME = author.name;
    process.env.AUTHOR_EMAIL = author.email;

  } else {
    core.warning('No event path available, unable to fetch author info.');

    process.env.AUTHOR_NAME = 'Tag & Commit Action';
    process.env.AUTHOR_EMAIL = 'navikt.bidrag-actions.git-tag-n-commit@github.com';
  }

  core.info(`Using '${process.env.AUTHOR_NAME} <${process.env.AUTHOR_EMAIL}>' as author.`);
}

// noinspection JSIgnoredPromiseFromCall
run();
