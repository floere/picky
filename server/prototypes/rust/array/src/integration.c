#include <stdio.h>
#include <stdint.h>

typedef struct struct_rust_array rust_array_t;

extern rust_array_t *
rust_array_new(void);

extern void
rust_array_free(rust_array_t *);

extern uint16_t
rust_array_append(const rust_array_t *, uint16_t item);

extern uint16_t
rust_array_first(const rust_array_t *);

extern uint16_t
rust_array_last(const rust_array_t *);

int main(void) {}