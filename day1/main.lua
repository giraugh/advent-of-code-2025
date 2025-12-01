-- Advent of code day 1 solution

local function get_input()
	-- Get input path
	local inputp = arg[1]
	if inputp == nil then
		print('no input path provided')
		return
	end

	-- Open the input file
	local inputf = io.open(inputp)
	if inputf == nil then
		print('no such input file')
		return
	end

	-- Read input
	local mlines = {}
	for line in inputf:lines() do
		table.insert(mlines, line)
	end

	-- Close input
	inputf:close()

	-- Return something...
	return mlines
end

-- Determine the direction and distance of a turn line
local function resolve_turn(turn)
	-- Which way to turn?
	local dir = string.sub(turn, 1, 1)
	local idir = 1
	if dir == 'L' then
		idir = -1
	end

	-- How far?
	local dist = tonumber(string.sub(turn, 2))

	return idir, dist
end

-- Part 1
local function simulate_turns1(turns)
	local resets = 0
	local dial = 50
	for _, turn in pairs(turns) do
		local idir, dist = resolve_turn(turn)
		dial = (dial + idir * dist) % 100
		if dial == 0 then
			resets = resets + 1
		end
	end
	return resets
end

-- Part 2 (brute forced)
local function simulate_turns2(turns)
	local resets = 0
	local dial = 50
	for _, turn in pairs(turns) do
		local idir, dist = resolve_turn(turn)
		for _ = 1, dist do
			dial = (dial + idir) % 100
			if dial == 0 then
				resets = resets + 1
			end
		end
	end
	return resets
end

-- Part 2 (analytical)
local function simulate_turns3(turns)
	local resets = 0
	local dial = 50
	for _, turn in pairs(turns) do
		local idir, dist = resolve_turn(turn)

		-- Account for full wraps
		local full_wraps = math.floor(dist / 100)
		resets = resets + full_wraps

		-- Then consider the rest of the movement
		local rem = dist % 100
		local roff = idir * rem
		local final = dial + roff

		if dial ~= 0 and (final <= 0 or final > 99) then
			resets = resets + 1
		end

		dial = (dial + roff) % 100
	end
	return resets
end

-- Get the puzzle instructions
local instructions = get_input()

-- Output solutions
print(simulate_turns1(instructions))
print(simulate_turns3(instructions))

-- Check my non-brute approach works
assert(simulate_turns2(instructions) == simulate_turns3(instructions))
