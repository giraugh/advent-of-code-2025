#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct BatteryBank {
  uint8_t len;
  uint8_t digits[128];
};

typedef int64_t bank_cache_t[256][256];

/** Compute 10^x for some int x */
int64_t pow10(int64_t x) {
  int64_t result = 1;
  while (x-- > 0) {
    result *= 10;
  }
  return result;
}

int64_t max_joltage_inner(struct BatteryBank *bank, bank_cache_t *cache,
                          uint8_t n, uint8_t c, uint8_t a) {
  // If we have a cached value, use that
  if ((*cache)[c][a] != -1) {
    return (*cache)[c][a];
  }

  // If we have used all available batteries, our additional contribution is 0
  if (c == n) {
    return 0;
  }

  // If we hit the end of the string and still didn't use full batteries this is
  // invalid, return a very negative value
  if (a == bank->len) {
    return INT64_MIN;
  }

  int64_t yes_val;
  int64_t no_val;

  // Whats the value we'll get if we do include the digit at `a`?
  int64_t contribution = bank->digits[a] * pow10((n - 1) - c);
  int64_t yes_inner = max_joltage_inner(bank, cache, n, c + 1, a + 1);
  if (yes_inner == INT64_MIN) {
    yes_val = INT64_MIN;
  } else {
    yes_val = contribution + yes_inner;
  }

  // What about if we dont?
  no_val = max_joltage_inner(bank, cache, n, c, a + 1);

  // What was higher?
  int64_t max_val = yes_val;
  if (no_val > yes_val) {
    max_val = no_val;
  }

  // Store in the cache
  (*cache)[c][a] = max_val;

  return max_val;
}

int64_t max_joltage(struct BatteryBank *bank, int n) {
  // init memoization cache
  // with sentinel (-1 = unset)
  // Cache key is (c, a)
  bank_cache_t cache;
  for (int x = 0; x <= 255; x++) {
    for (int y = 0; y <= 255; y++) {
      cache[x][y] = -1;
    }
  }

  return max_joltage_inner(bank, &cache, n, 0, 0);
}

int main(int argc, char *argv[]) {
  // Okay so, C huh?
  // lets figure out the path
  // do we have one?
  if (argc < 2) {
    return 1;
  }

  // Open the provided file
  char *path = argv[1];
  FILE *input_file = fopen(path, "r");

  // Read line by line
  // Set aside memory for each line (they max out at about 100chars)
  char line[128];
  int64_t p1sum = 0;
  int64_t p2sum = 0;
  while (fscanf(input_file, "%127s", line) == 1) {
    // Interpret the line as digits and store in a "BatteryBank" struct
    struct BatteryBank bank = {.len = 0, .digits = {}};
    bank.len = strlen(line);
    for (int i = 0; i < bank.len; i++) {
      bank.digits[i] = line[i] - '0';
    }

    // Now lets use this bank
    p1sum += max_joltage(&bank, 2);
    p2sum += max_joltage(&bank, 12);
  }

  // Report answers
  printf("p1=%lld\n", p1sum);
  printf("p2=%lld\n", p2sum);

  // Close the file
  if (fclose(input_file)) {
    perror("Failed to close file");
    return 1;
  }

  return 0;
}
