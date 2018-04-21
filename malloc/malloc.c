#include <stdlib.h>
#include <string.h>
#include <stdio.h>

static uint8_t MEMORY_POOL[64];
static uint64_t MEMORY_POOL_USED = 0;

void *malloc(size_t size) {
  void *ptr;

  ptr = MEMORY_POOL + MEMORY_POOL_USED;
  MEMORY_POOL_USED += size;

  return ptr;
}

void free(void *ptr) {
}

int main() {
  char *a;
  char *b;
  char *c;
  char *d;

  a = malloc(4);
  b = malloc(4);
  c = malloc(4);

  strcpy(a, "foo\0");
  strcpy(b, "bar\0");
  strcpy(c, "baz\0");

  printf("%p\n", a);
  printf("%p\n", b);
  printf("%p\n", c);

  free(b);
  d = malloc(4);

  printf("%p\n", d);
}
