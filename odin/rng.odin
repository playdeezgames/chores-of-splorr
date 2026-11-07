package chores

// Small deterministic generator (splitmix64) so tests can seed it and the
// wasm build never depends on the platform's default RNG (vault Gotchas).
Rng :: struct {
	state: u64,
}

rng_seed :: proc(r: ^Rng, seed: u64) {
	r.state = seed
}

rng_next :: proc(r: ^Rng) -> u64 {
	r.state += 0x9E3779B97F4A7C15
	z := r.state
	z = (z ~ (z >> 30)) * 0xBF58476D1CE4E5B9
	z = (z ~ (z >> 27)) * 0x94D049BB133111EB
	return z ~ (z >> 31)
}

// Uniform integer in [lo, hi], inclusive, like Lua's math.random(lo, hi).
rng_range :: proc(r: ^Rng, lo, hi: int) -> int {
	if hi <= lo {
		return lo
	}
	span := u64(hi - lo + 1)
	return lo + int(rng_next(r) % span)
}
