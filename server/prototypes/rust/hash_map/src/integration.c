#include <stdio.h>
#include <stdint.h>

typedef struct struct_rust_hash_map rust_hash_map_t;

extern rust_hash_map_t *
rust_hash_map_new(void);

extern void
rust_hash_map_free(rust_hash_map_t *);

extern uint32_t
rust_hash_map_set(const rust_hash_map_t *, const char *key, uint32_t value);

extern uint32_t
rust_hash_map_get(const rust_hash_map_t *, const char *key);

int main(void) {}