module.exports = {
  title: "chrony tests",
  tests: [
    {
      title: "Chronyd service",
      run: async function (test) {
        let result = "";
        result = await this.context
          .get()
          .worker.executeCommandInHostOS(
            "systemctl status chronyd | grep running",
            this.context.get().link
          );
        test.is(result !== "", true, "Chronyd service should be running");
      },
    },
    {
      title: "Sync test",
      run: async function (test) {
        let result = "";
        test.comment("checking system clock synchronized...");
        await this.context.get().utils.waitUntil(async () => {
          result = await this.context
            .get()
            .worker.executeCommandInHostOS(
              "timedatectl | grep System",
              this.context.get().link
            );
          return result === "System clock synchronized: yes";
        });
        result = await this.context
          .get()
          .worker.executeCommandInHostOS(
            "timedatectl | grep System",
            this.context.get().link
          );
        test.is(
          result,
          "System clock synchronized: yes",
          "System clock should be synchronized"
        );
      },
    },
    {
      title: "Source test",
      run: async function (test) {
        let result = "";
        result = await this.context
          .get()
          .worker.executeCommandInHostOS(
            `chronyc sources -n | fgrep '^*'`,
            this.context.get().link
          );
        test.is(result !== "", true, "Should see ^* next to chrony source");
      },
    },
  ],
};
