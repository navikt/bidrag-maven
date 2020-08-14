const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  try {
    const urls = core.getInput('repositories');
    const m2home = core.getInput('maven_home');

    // Execute tag bash script
    await exec.exec(`${__dirname}/../setup.sh`, [urls, m2home]);

  } catch (error) {
    core.setFailed(error.message);
  }
}

// noinspection JSIgnoredPromiseFromCall
run();
