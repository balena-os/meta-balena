// SPDX-License-Identifier: GPL-2.0+

/* Helper command for saving and comparing CRC32 of the memory areas
 * where the kernel and device-tree are loaded. Keeps env_resin
 * changes to a minimum.
 */

#include <common.h>
#include <config.h>
#include <command.h>
#include <env.h>
#include <hash.h>
#include <vsprintf.h>

static int do_save_crc32(cmd_tbl_t *cmdtp, int flag, int argc, char * const argv[], bool final)
{
	char *loadAddress = NULL, *hashArray[5];
	char saveVar[64] = { 0 }, saveSizeVar[32] = { 0 }, *countStr;

	snprintf(saveSizeVar, sizeof(saveSizeVar), "%s%s", argv[0], "_size" /* i.e fdt_addr_size */);

	/* u-boot env variable name where the kernel or fdt is loaded, e.g loadaddr, fdt_addr, fdtaddr */
	loadAddress = env_get(argv[0]);
	if (!loadAddress) {
		printf("Address variable not set!\n");
		return CMD_RET_FAILURE;
	}

	/* crc32 will be saved in a variable like loadaddr_crc32 or loadaddr_crc32_final */
	snprintf(saveVar, sizeof(saveVar), "%s%s", argv[0], final ? "_crc32_final" : "_crc32");

	if (final) {
		countStr = env_get(saveSizeVar);
		if (!countStr) {
			printf("Size was not saved - Invalid usage!\n");
			return CMD_RET_FAILURE;
		}
	} else {
		countStr = env_get("filesize");
                if (!countStr) {
                        printf("No file was loaded - Invalid usage!\n");
                        return CMD_RET_FAILURE;
                }
		env_set(saveSizeVar, countStr);
	}

	/* arg 0 must be the command text as per the hash command docs */
	hashArray[0] = "hash";
	hashArray[1] = "crc32";
	hashArray[2] = loadAddress;
	hashArray[3] = countStr;
	hashArray[4] = saveVar;

	return hash_command("crc32" /* algo */, HASH_FLAG_ENV, cmdtp, flag, 4 /* argc */, hashArray + 2);
}

static int do_check_crc32(cmd_tbl_t *cmdtp, int flag, int argc, char * const argv[])
{
	char pre[64], post[64], *preVal, *postVal;

	if (!argv[0]) {
		printf("Address variable not provided!\n");
		return CMD_RET_FAILURE;
	}

	snprintf(pre, sizeof(pre), "%s_crc32", argv[0]);
	snprintf(post, sizeof(post), "%s_crc32_final", argv[0]);

	do_save_crc32(cmdtp, flag, argc, argv, true /* final check */);

	preVal = env_get(pre);
	postVal = env_get(post);

	if (preVal && postVal && !strncmp(preVal, postVal, 8 /* crc32 is 8 chars */)) {
		printf("CRC32 match for $%s: %s\n", argv[0], preVal);
	} else {
		printf("CRC32 mismatch for $%s, before: %s, after %s\n", argv[0], preVal, postVal);
		return CMD_RET_FAILURE;
	}

	return CMD_RET_SUCCESS;
}

static int do_balena_crc32(cmd_tbl_t *cmdtp, int flag, int argc,
		   char *const argv[])
{
	if (argc < 3)
		return CMD_RET_USAGE;

	if (!strcmp(argv[1], "save")) {
		return do_save_crc32(cmdtp, flag, argc - 2, argv + 2, false /* initial check */);
	} else if (!strcmp(argv[1], "check")) {
		return do_check_crc32(cmdtp, flag, argc - 2, argv + 2);
	}

	return CMD_RET_USAGE;
}

/* Can be called from cmdline as:
 *  $ balena_crc32 save loadaddr
 *  $ if test balena crc32 check loadaddr; then do_nothing; else save warning_file; fi;
 */
U_BOOT_CMD(
	balena_crc32,	CONFIG_SYS_MAXARGS,	1,	do_balena_crc32,
	"balenaOS crc32 verification commands",
	"save <fdtaddr/loadaddr>\n"
	"    - save crc32 for fdtaddr or loadaddr in <fdtaddr/loadaddr>_crc32\n"
	"check <fdtaddr/kerneladdr>\n"
	"    - Re-calculate and compare crc32 for <fdtaddr/loadaddr> with the one already stored\n"
);
