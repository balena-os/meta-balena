const fs = require("fs");

module.exports = {
  title: "kernel-overlap test",
  run: async function (test) {
    const fileContents = fs.readFileSync(`${__dirname}/script.sh`).toString();

    const script = await this.context
      .get()
      .worker.executeCommandInHostOS(
        `cd /tmp && ${fileContents}`,
        this.context.get().link
      );

    test.is(
      script.includes("ok"),
      true,
      "kernel-overlap script should return ok"
    );
  },
};
