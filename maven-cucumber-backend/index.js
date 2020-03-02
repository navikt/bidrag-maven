const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  try {
    // Execute cucumber bash script
    await exec.exec(`${__dirname}/cucumber.sh`);
  } catch (error) {
    core.setFailed(error.message);
  }
}

run();
