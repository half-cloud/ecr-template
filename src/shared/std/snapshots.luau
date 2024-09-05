local ecr = require("@packages/ecr")
local types = require("./types")

local ID_SIZE = ecr.id_size
local REMOVED = newproxy()

type Array<T> = { [number]: T }
type Map<K, V> = { [K]: V }
type Pool<T> = types.Pool<T>
type Registry = ecr.Registry
type Snapshot = types.Snapshot
type SnapshotDeserializeOptions = types.SnapshotDeserializeOptions
type SnapshotSerializeOptions = types.SnapshotSerializeOptions

local function clone_pool_ids<T>(pool: Pool<T>): buffer
	local b = buffer.create(pool.size * ID_SIZE)
	buffer.copy(b, 0, pool.entities, 0, pool.size * ID_SIZE)
	return b
end

local exports = {}

function exports.create_snapshot(
	cts: Map<string, unknown>,
	registry: Registry,
	options: Map<string, SnapshotSerializeOptions?>
): Snapshot
	local snapshot: Snapshot = { ctypes = {} }

	for cname, ctype in cts do
		local copts = options[cname]
		local pool = registry:storage(ctype)
		local values = table.clone(pool.values)

		local serialize = copts and copts.serialize
		if serialize ~= nil then
			for index, value in values do
				values[index] = serialize(value)
			end
		end

		snapshot.ctypes[cname] = {
			set = clone_pool_ids(pool),
			values = values,
		}
	end

	return snapshot
end

function exports.create_diff_generator(
	cts: Map<string, unknown>,
	registry: Registry,
	options: Map<string, SnapshotSerializeOptions?>
): () -> Snapshot?
	local changes: Map<unknown, Map<number, unknown>> = {}

	for cname, ctype in cts do
		local map: Map<number, unknown> = {}

		if ecr.is_tag(ctype) then
			registry:on_add(ctype):connect(function(id)
				map[id] = true
			end)
		else
			registry:on_add(ctype):connect(function(id, value)
				map[id] = value
			end)
		end

		local copts = options[cname]
		local replicate_add_only = copts and copts.replicate_add_only

		if replicate_add_only ~= true then
			registry:on_change(ctype):connect(function(id, value)
				map[id] = value
			end)

			registry:on_remove(ctype):connect(function(id)
				map[id] = REMOVED
			end)
		end

		changes[ctype] = map
	end

	return function()
		local snapshot: Snapshot = { ctypes = {} }

		local destroyed_ids: Array<number> = {}
		local destroyed_n = 0

		for cname, ctype in cts do
			local map = changes[ctype]
			if next(map) == nil then
				continue
			end

			local removed_ids: Array<number> = {}
			local set_ids: Array<number> = {}
			local set_values: Array<unknown> = {}

			local removed_n = 0
			local set_n = 0

			for id, value in map do
				if value ~= REMOVED then
					set_n += 1
					set_ids[set_n] = id
					set_values[set_n] = value
				elseif registry:contains(id) == true then
					removed_n += 1
					removed_ids[removed_n] = id
				else
					destroyed_n += 1
					destroyed_ids[destroyed_n] = id
				end
			end

			local copts = options[cname]
			local serialize = copts and copts.serialize

			if serialize ~= nil then
				for index, value in set_values do
					set_values[index] = serialize(value)
				end
			end

			snapshot.ctypes[cname] = {
				removed = removed_n > 0 and ecr.array_to_buffer(removed_ids, removed_n) or nil,
				set = set_n > 0 and ecr.array_to_buffer(set_ids, set_n) or nil,
				values = (set_n > 0 and not ecr.is_tag(ctype)) and set_values or nil,
			}

			table.clear(map)
		end

		if destroyed_n > 0 then
			snapshot.destroyed = ecr.array_to_buffer(destroyed_ids, destroyed_n)
		end

		return if snapshot.destroyed ~= nil and next(snapshot.ctypes) ~= nil then snapshot else nil
	end
end

function exports.load_snapshot(
	cts: Map<string, unknown>,
	registry: Registry,
	snapshot: Snapshot,
	options: Map<string, SnapshotDeserializeOptions?>
): ()
	local destroyed = snapshot.destroyed
	if destroyed ~= nil then
		for i = 0, buffer.len(destroyed) - 1, ID_SIZE do
			local id = buffer.readu32(destroyed, i)
			if registry:contains(id) == true then
				registry:destroy(id)
			end
		end
	end

	for cname, changes in snapshot.ctypes do
		local ctype = cts[cname]

		local copts = options[cname]
		local filter = copts and copts.filter

		local removed_ids = changes.removed
		local set_ids = changes.set
		local set_values = changes.values

		if removed_ids ~= nil then
			for i = 0, buffer.len(removed_ids) - 1, ID_SIZE do
				local id = buffer.readu32(removed_ids, i)

				if registry:contains(id) == true then
					if filter and filter(registry, id) == false then
						continue
					end

					registry:remove(id, ctype)
				else
					registry:create(id)
				end
			end
		end

		if set_ids ~= nil then
			if ecr.is_tag(ctype) == true then
				set_values = {}
			end

			assert(set_values, "")

			local deserialize = copts and copts.deserialize
			if deserialize ~= nil then
				for index, value in set_values do
					set_values[index] = deserialize(value)
				end
			end

			local j = 0
			for i = 0, buffer.len(set_ids) - 1, ID_SIZE do
				j += 1

				local id = buffer.readu32(set_ids, i)

				if registry:contains(id) == false then
					registry:create(id)
				end

				if filter ~= nil and filter(registry, id) == false then
					continue
				end

				registry:set(id, ctype, set_values[j])
			end
		end
	end
end

return exports
