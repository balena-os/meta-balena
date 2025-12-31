#include <linux/module.h>
#include <linux/init.h>
#include <linux/firmware.h>
#include <linux/string.h>

#define FW_NAME "test_extra_firmware.bin"
#define MAGIC_STRING "balena"
#define MAGIC_STRING_LEN 6

static int __init hello_init(void)
{
	const struct firmware *fw = NULL;
	int ret;

	pr_info("hello: requesting firmware '%s'\n", FW_NAME);

	ret = request_firmware_direct(&fw, FW_NAME, NULL);
	if (ret) {
		pr_err("hello: firmware '%s' NOT FOUND (err=%d)\n", FW_NAME, ret);
		return 0;
	}

	pr_info("hello: SUCCESS - firmware '%s' loaded, size=%zu bytes\n", FW_NAME, fw->size);

	if (fw->size >= MAGIC_STRING_LEN && memcmp(fw->data, MAGIC_STRING, MAGIC_STRING_LEN) == 0) {
		pr_info("hello: VERIFIED - firmware content matches expected magic '%s'\n", MAGIC_STRING);
	} else {
		pr_err("hello: MISMATCH - firmware content does not start with '%s'\n", MAGIC_STRING);
	}

	release_firmware(fw);
	return 0;
}

static void __exit hello_exit(void)
{
	pr_info("hello: unloaded\n");
}

module_init(hello_init);
module_exit(hello_exit);
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("Test module for extra firmware path validation");
