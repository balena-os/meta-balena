KERNEL_TREE_PATH?=/lib/modules/$(shell uname -r)/build
MODULE_PATH?=$(PWD)
EXTRA_CFLAGS="-DDEBUG"

obj-m+=hello.o

all: hello.ko

hello.ko: hello.c
	make -C $(KERNEL_TREE_PATH) M=$(MODULE_PATH) modules

clean:
	make -C $(KERNEL_TREE_PATH) M=$(MODULE_PATH) clean

.PHONY: all clean
