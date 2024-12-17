type Array<T> = { T }

export type Node<T...> = (T...) -> unknown

local SUCCESS = true
local FAILURE = false
local RUNNING = newproxy()

local bt = {}

bt.running = RUNNING

function bt.fallback<T...>(children: Array<Node<T...>>): Node<T...>
	return function(...: T...)
		for _, node in children do
			local status = node(...)
			if status or status == RUNNING then
				return status
			end
		end

		return FAILURE
	end
end

function bt.sequence<T...>(children: Array<Node<T...>>): Node<T...>
	return function(...: T...)
		for _, node in children do
			local status = node(...)
			if not status or status == RUNNING then
				return status
			end
		end

		return SUCCESS
	end
end

function bt.check<T...>(condition: (T...) -> unknown): Node<T...>
	return function(...: T...)
		local status = condition(...)
		return if status ~= RUNNING then status else error("condition check cannot return running", 2)
	end
end

function bt.invert<T...>(node: Node<T...>): Node<T...>
	return function(...: T...)
		local status = node(...)
		return status == RUNNING and RUNNING or not status
	end
end

function bt.succeed<T...>(node: Node<T...>): Node<T...>
	return function(...: T...)
		node(...)
		return SUCCESS
	end
end

return table.freeze(bt)