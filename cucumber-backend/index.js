const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  try {
    const doNotFail = core.getInput('do_not_fail');
    const mavenCommand = core.getInput('maven_command');
    const mavenImage = core.getInput('maven_image');
    const testUser = core.getInput('test_user');
    const username = core.getInput('username');

    // Execute cucumber bash script
    await exec.exec(
        `${__dirname}/cucumber.sh ${doNotFail} ${mavenCommand} ${mavenImage} ${testUser} ${username}`
    );
  } catch (error) {
    core.setFailed(error.message);
  }
}

// noinspection JSIgnoredPromiseFromCall
run();
