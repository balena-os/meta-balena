#include <linux/init.h>
#include <linux/module.h>
#include <linux/printk.h>

static int __init crc_gate_init(void)
{
	/* pr_info references _printk, the symbol the gate checks. */
	pr_info("crc_gate: loaded\n");
	return 0;
}

static void __exit crc_gate_exit(void)
{
}

module_init(crc_gate_init);
module_exit(crc_gate_exit);

MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("Symbol CRC gate probe for extension tests");
