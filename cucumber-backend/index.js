const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  try {
    const useNaisConfiguration = core.getInput('use_nais_configuration');
    const runFromWorkspace = core.getInput('run_from_workspace');

    // Execute clone bash script to setup running bidrag-cucumber-backend
    const exitCode = await exec.exec(
        `${__dirname}/../clone-cucumber.sh`,
        [useNaisConfiguration, runFromWorkspace]
    );

    if (exitCode === 0) {
      const cucumberTag = core.getInput('cucumber_tag');
      const doNotFail = core.getInput('do_not_fail');
      const mavenCommand = core.getInput('maven_command');
      const mavenImage = core.getInput('maven_image');
      const testUser = core.getInput('test_user');
      const username = core.getInput('username');

      // Execute cucumber bash script
      await exec.exec(
          `${__dirname}/../cucumber.sh`,
          [cucumberTag, doNotFail, mavenCommand, mavenImage, runFromWorkspace, testUser, useNaisConfiguration, username]
      );
    }
  } catch (error) {
    core.setFailed(error.message);
  }
}

// noinspection JSIgnoredPromiseFromCall
run();
