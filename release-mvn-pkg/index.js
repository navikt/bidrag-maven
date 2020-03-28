const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  try {
    const isReleaseCandidate = core.getInput('is_release_candidate');
    const newSnapshotVersion = core.getInput('new_snapshot_version');
    const releaseVersion = core.getInput('release_version');

    // Execute release bash script
    await exec.exec(
        `bash ${__dirname}/release.sh ${isReleaseCandidate} ${newSnapshotVersion} ${releaseVersion}`
    );

  } catch (error) {
    core.setFailed(error.message);
  }
}

run();
