const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  try {
    const newSnapshotVersion = core.getInput('new_snapshot_version');
    const releaseVersion = core.getInput('release_version');

    // Execute prepare-release bash script
    await exec.exec(
        `bash ${__dirname}/prepare-release.sh ${newSnapshotVersion} ${releaseVersion}`
    );

  } catch (error) {
    core.setFailed(error.message);
  }
}

run();
