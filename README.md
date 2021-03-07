# jsonata-c 

C bindings for [JSONata](https://jsonata.org).


## Building

Required build tools:
* npm
* clang
* make

To build:

```
make
```

To strip symbols (saves about 60k):

```
make strip
```

Or to build in release mode, with optimizations and security flags enabled:

```
make release
```


## Testing

### Fuzzing

The Duktape + jsonata.js binary can be built as an executable in-process
fuzzing binary, which allows fuzzing JSONata expressions and input JSON.

To build a target for fuzzing input JSON:

```
make FUZZTARGET=JSON fuzz
```

To build a target for fuzzing JSONata expressions:

```
make FUZZTARGET=EXPRESSION fuzz
```

Omitting `FUZZTARGET` will build the `JSON` target.

By default, these targets are built with ASAN enabled. You can override this
with `CFLAGS=-fno-sanitize=address`, or use others such as UBSan with
`CFLAGS=-fsanitize=address,undefined`.

The usual libFuzzer parameters are accepted. You must also provide, as the last
argument, the path to a file containing either a JSONata expression or an input
JSON, depending on the target. If you built the expression target, provide an
in put JSON for generated expression to process. If you built the JSON target,
provide an expression to use. For example, for the expression target:

```
./translate -rss_limit_mb=0 -jobs=4 -workers=4 ./tests/inputs/test_1.input.json
```

## Usage

```c
const char my_expr = "$";
const char my_json = "{'hello': 'world'}"
char *result;
const char *error;
int rc;

rc = jsonata(expression, my_json, &result, &error);

if (rc == JSONATA_SUCCESS)
	printf("Result: %s\n", result);
else
	printf("Error: %s\n", error);

free(result);
```

*Always* free on `result`. In the error case, `result` is guaranteed to be
null, so you don't need to check it.

That's it!
