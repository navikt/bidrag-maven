const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  try {
    const cucumberTag = core.getInput('cucumber_tag');
    const doNotFail = core.getInput('do_not_fail');
    const githubProj = core.getInput('github_project');
    const mavenCommand = core.getInput('maven_command');
    const mavenImage = core.getInput('maven_image');
    const naisProjectFolder = core.getInput('nais_project_folder');
    const testUser = core.getInput('test_user');
    const username = core.getInput('username');

    // Execute cucumber bash script
    await exec.exec(
        `${__dirname}/../cucumber.sh`,
        [
          cucumberTag, doNotFail, githubProj, mavenCommand, mavenImage,
          naisProjectFolder, testUser, username
        ]
    );
  } catch (error) {
    core.setFailed(error.message);
  }
}

// noinspection JSIgnoredPromiseFromCall
run();
