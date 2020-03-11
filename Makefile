local_LDFLAGS=-fPIC
local_CFLAGS=-Wall -O3 -std=gnu99 -I. -Isrc
FUZZFLAGS=-g3 -fsanitize=fuzzer -fsanitize=address -DFUZZING
FUZZTARGET=JSON

CC=gcc
LIBS=-lm
VPATH=src

jsonata.so: jsonata-es5.min.js duktape.o jsonata.c
	$(CC) $(local_CFLAGS) $(CFLAGS) $(local_LDFLAGS) $(LDFLAGS) $(LIBS) -shared -o jsonata.so src/jsonata.c duktape.o

jsonata.c:
	$(shell cat src/jsonata-es5.min.js | base64 | sed 's/$$/\\/g' | sed -e '/.*REPLACE_ME/ {' -e 'r /dev/stdin' -e 'd' -e '}' src/jsonata.c.in > src/jsonata.c)

jsonata-es5.min.js:
	cd jsonata; npm install; npm run build-es5; cp jsonata-es5.min.js ../src/

duktape.o: duktape.c duktape.h duk_config.h
	$(CC) $(local_CFLAGS) $(CFLAGS) $(local_LDFLAGS) $(LDFLAGS) -c -o duktape.o src/duktape.c

fuzz: local_CFLAGS += $(FUZZFLAGS)
fuzz: duktape.o jsonata.so
fuzz:
	$(CC) $(local_CFLAGS) $(CFLAGS) $(local_LDFLAGS) $(LDFLAGS) $(FUZZFLAGS) -DFUZZ_$(FUZZTARGET) $(LIBS) -o jsonata-fuzz src/jsonata.c duktape.o

check: jsonata.so
	python3 -m pytest

clean:
	rm -f src/jsonata.c src/*.o *.o jsonata.so jsonata-fuzz jsonata/*jsonata-es5.min.js

strip: jsonata.so
	strip --strip-unneeded jsonata.so

release: local_CFLAGS += -fstack-protector
release: clean strip
