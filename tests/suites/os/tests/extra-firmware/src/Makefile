KERNEL_TREE_PATH?=/lib/modules/$(shell uname -r)/build
EXTRA_CFLAGS="-DDEBUG"

obj-m+=hello.o

all: hello.ko

hello.ko: hello.c
	make -C $(KERNEL_TREE_PATH) M=$(PWD) modules

clean:
	make -C $(KERNEL_TREE_PATH) M=$(PWD) clean

.PHONY: all clean
