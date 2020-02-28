local_LDFLAGS=-fPIC
local_CFLAGS=-Wall -O3 -std=gnu99 -I.
FUZZFLAGS=-g3 -fsanitize=fuzzer -fsanitize=address -DFUZZING
FUZZTARGET=JSON

CC=gcc
LIBS=-lm
VPATH=src

jsonata.so: jsonata.h duktape.o jsonata.c
	$(CC) $(local_CFLAGS) $(CFLAGS) $(local_LDFLAGS) $(LDFLAGS) $(LIBS) -shared -o jsonata.so src/jsonata.c duktape.o

fuzz: local_CFLAGS += $(FUZZFLAGS)
fuzz: duktape.o jsonata.so
fuzz:
	$(CC) $(local_CFLAGS) $(CFLAGS) $(local_LDFLAGS) $(LDFLAGS) $(FUZZFLAGS) -DFUZZ_$(FUZZTARGET) $(LIBS) -o jsonata-fuzz src/jsonata.c duktape.o

duktape.o: duktape.c duktape.h duk_config.h
	$(CC) $(local_CFLAGS) $(CFLAGS) $(local_LDFLAGS) $(LDFLAGS) -c -o duktape.o src/duktape.c

jsonata.h: jsonata-es5.min.js
	$(shell cat jsonata/jsonata-es5.min.js | base64 | sed 's/$$/\\/g' | sed -e '/.*REPLACE_ME/ {' -e 'r /dev/stdin' -e 'd' -e '}' src/jsonata.h.template > src/jsonata.h)

jsonata-es5.min.js:
	cd jsonata; npm install; npm run build-es5; cp jsonata-es5.min.js ../src/

check: jsonata.so
	python3 -m pytest

clean:
	rm -f src/jsonata.h *.o jsonata.so jsonata-fuzz

strip: jsonata.so
	strip --strip-unneeded jsonata.so

release: local_CFLAGS += -fstack-protector
release: clean strip
