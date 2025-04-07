CFLAGS = -std=c99 -Wall -pedantic -DALTA_IMPLEMENTATION -DUSE_PREBUILT_MAIN

all: output

output: output.c
	$(CC) $(CFLAGS) $< -o $@

.PHONY: run clean

run: output
	./$<

clean:
	rm -f output
