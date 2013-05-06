-------------------------------------------------------------------------------
-- This is the analog of the 'main' function when invoking qsome directly, as
-- apposed to for use within another library
-------------------------------------------------------------------------------
local QsomeAPI = {}

QsomeAPI['queue.subqueues'] = function(now, queue)
    return cjson.encode(Qsome.queue(queue):subqueues())
end

QsomeAPI['queue.resize'] = function(now, queue, size)
    return Qsome.queue(queue):resize(size)
end

QsomeAPI['queue.put'] = function(
    now, queue, jid, klass, hash, data, delay, ...)
    return Qsome.queue(queue):put(
        now, jid, klass, hash, data, delay, unpack(arg))
end

QsomeAPI['queue.pop'] = function(now, queue, worker, count)
    local jids = Qsome.queue(queue):pop(now, worker, count)
    local response = {}
    for i, jid in ipairs(jids) do
        table.insert(response, Qsome.job(jid):data())
    end
    return cjson.encode(response)
end

-- -- Return json for the job identified by the provided jid. If the job is not
-- -- present, then `nil` is returned
-- function QsomeAPI.get(now, jid)
--     local data = Qsome.job(jid):data()
--     if not data then
--         return nil
--     end
--     return cjson.encode(data)
-- end

-- -- Public access
-- QsomeAPI['config.get'] = function(now, key)
--     return cjson.encode(Qless.config.get(key))
-- end

-- QsomeAPI['config.set'] = function(now, key, value)
--     return Qless.config.set(key, value)
-- end

-- -- Unset a configuration option
-- QsomeAPI['config.unset'] = function(now, key)
--     return Qless.config.unset(key)
-- end

-- -- Get information about a queue or queues
-- QsomeAPI.queues = function(now, queue)
--     return cjson.encode(Qsome.queues(now, queue))
-- end

QsomeAPI.complete = function(now, jid, worker, queue, data, ...)
    return Qsome.job(jid):complete(now, worker, queue, data, unpack(arg))
end

-- QsomeAPI.failed = function(now, group, start, limit)
--     return cjson.encode(Qless.failed(group, start, limit))
-- end

-- QsomeAPI.fail = function(now, jid, worker, group, message, data)
--     return Qless.job(jid):fail(now, worker, group, message, data)
-- end

-- QsomeAPI.jobs = function(now, state, ...)
--     return Qless.jobs(now, state, unpack(arg))
-- end

-- QsomeAPI.retry = function(now, jid, queue, worker, delay)
--     return Qless.job(jid):retry(now, queue, worker, delay)
-- end

-- QsomeAPI.depends = function(now, jid, command, ...)
--     return Qless.job(jid):depends(command, unpack(arg))
-- end

-- QsomeAPI.heartbeat = function(now, jid, worker, data)
--     return Qless.job(jid):heartbeat(now, worker, data)
-- end

-- QsomeAPI.workers = function(now, worker)
--     return cjson.encode(Qless.workers(now, worker))
-- end

-- QsomeAPI.track = function(now, command, jid)
--     return cjson.encode(Qless.track(now, command, jid))
-- end

-- QsomeAPI.tag = function(now, command, ...)
--     return cjson.encode(Qless.tag(now, command, unpack(arg)))
-- end

-- QsomeAPI.stats = function(now, queue, date)
--     return cjson.encode(Qless.queue(queue):stats(now, date))
-- end

-- QsomeAPI.priority = function(now, jid, priority)
--     return Qless.job(jid):priority(priority)
-- end

-- QsomeAPI.peek = function(now, queue, count)
--     return cjson.encode(Qless.queue(queue):peek(now, count))
-- end

-- QsomeAPI.pop = function(now, queue, worker, count)
--     return cjson.encode(Qless.queue(queue):pop(now, worker, count))
-- end

-- QsomeAPI.pause = function(now, ...)
--     return Qless.pause(unpack(arg))
-- end

-- QsomeAPI.unpause = function(now, ...)
--     return Qless.unpause(unpack(arg))
-- end

-- QsomeAPI.cancel = function(now, ...)
--     return Qless.cancel(unpack(arg))
-- end

-- QsomeAPI.put = function(now, queue, jid, klass, hsh, data, delay, ...)
--     return Qsome.queue(queue):put(
--         now, jid, klass, hsh, data, delay, unpack(arg))
-- end

-- QsomeAPI.unfail = function(now, queue, group, count)
--     return Qless.queue(queue):unfail(now, group, count)
-- end

-- -- Recurring job stuff
-- QsomeAPI.recur = function(now, queue, jid, klass, hsh, data, spec, ...)
--     return Qless.queue(queue):recur(
--         now, jid, klass, hsh, data, spec, unpack(arg))
-- end

-- QsomeAPI.unrecur = function(now, jid)
--     return Qless.recurring(jid):unrecur()
-- end

-- QsomeAPI['recur.get'] = function(now, jid)
--     return cjson.encode(Qless.recurring(jid):data())
-- end

-- QsomeAPI['recur.update'] = function(now, jid, ...)
--     return Qless.recurring(jid):update(unpack(arg))
-- end

-- QsomeAPI['recur.tag'] = function(now, jid, ...)
--     return Qless.recurring(jid):tag(unpack(arg))
-- end

-- QsomeAPI['recur.untag'] = function(now, jid, ...)
--     return Qless.recurring(jid):untag(unpack(arg))
-- end

-- QsomeAPI.length = function(now, queue)
--     return Qless.queue(queue):length()
-- end

-------------------------------------------------------------------------------
-- Function lookup
-------------------------------------------------------------------------------

-- None of the qless function calls accept keys
if #KEYS > 0 then erorr('No Keys should be provided') end

-- The first argument must be the function that we intend to call, and it must
-- exist
local command_name = assert(table.remove(ARGV, 1), 'Must provide a command')
local command      = assert(
    QsomeAPI[command_name], 'Unknown command ' .. command_name)

-- The second argument should be the current time from the requesting client
local now          = tonumber(table.remove(ARGV, 1))
local now          = assert(
    now, 'Arg "now" missing or not a number: ' .. (now or 'nil'))

return command(now, unpack(ARGV))
