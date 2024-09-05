local ecr = require("@packages/ecr")

type Array<T> = { [number]: T }
type Registry = ecr.Registry

export type SnapshotDeserializeOptions = {
	deserialize: ((value: unknown) -> unknown)?,
	filter: ((registry: Registry, id: number) -> boolean)?,
}

export type SnapshotSerializeOptions = {
	ignore_changes_if: ((id: number) -> boolean)?,
	replicate_add_only: boolean?,
	serialize: ((value: unknown) -> unknown)?,
}

export type Pool<T> = { entities: buffer, size: number, values: Array<T> }
export type Snapshot = {
	ctypes: { [string]: { removed: buffer?, set: buffer?, values: Array<unknown>? } },
	destroyed: buffer?,
}

export type SystemFn<T> = (registry: Registry, state: T, delta_time: number) -> ()
export type System<T> = {
	run_interval: number?,
	run_once: boolean?,
	stateful: boolean?,
	system: SystemFn<T>,
}

return nil
