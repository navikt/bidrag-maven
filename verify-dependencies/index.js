const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  try {
    // Execute verify bash script
    await exec.exec(`${__dirname}/../verify.sh`);
  } catch (error) {
    core.setFailed(error.message);
  }
}

run();
