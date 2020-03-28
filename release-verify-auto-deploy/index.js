const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  try {
    const changelogFile = core.getInput('changelog_file');
    const releaseVersion = core.getInput('release_version');

    // Execute verify-deploy bash script
    await exec.exec(
        `bash ${__dirname}/verify-deploy.sh ${changelogFile} ${releaseVersion}`
    );

  } catch
      (error) {
    core.setFailed(error.message);
  }
}

run();
