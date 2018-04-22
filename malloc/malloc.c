#include <stdlib.h>
#include <string.h>
#include <stdio.h>

static uint8_t MEMORY_POOL[64];

struct free_entry {
  void *ptr;
  uint64_t size;
};
typedef struct free_entry free_entry_t;

static free_entry_t FREE_LIST[64] = {
  (free_entry_t){
    .ptr = MEMORY_POOL,
    .size = 64,
  },
};
static uint64_t FREE_LIST_USED = 1;

free_entry_t *find_free_entry(size_t size) {
  free_entry_t *best_entry = FREE_LIST;

  for (uint64_t i = 0; i < FREE_LIST_USED; i++) {
    free_entry_t *entry;
    entry = &FREE_LIST[i];

    if (entry->size >= size && entry->size < best_entry->size) {
      best_entry = entry;
    }
  }

  return best_entry;
}

void *malloc(size_t size) {
  size += 8; // size metadata

  free_entry_t *entry;
  entry = find_free_entry(size);

  void *base_ptr;
  uint64_t *size_ptr;
  void *user_ptr;

  base_ptr = entry->ptr;
  size_ptr = base_ptr;
  user_ptr = base_ptr + 8;

  *size_ptr = size;

  entry->ptr += size;
  entry->size -= size;


  return user_ptr;
}

void free(void *user_ptr) {
  free_entry_t *entry;
  entry = &FREE_LIST[FREE_LIST_USED];

  void *base_ptr;
  uint64_t *size_ptr;
  uint64_t size;

  base_ptr = user_ptr - 8;
  size_ptr = base_ptr;

  size = *size_ptr;

  entry->ptr = base_ptr;
  entry->size = size;

  FREE_LIST_USED++;
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
