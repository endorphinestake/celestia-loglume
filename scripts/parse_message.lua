function cb_clean_and_split(tag, ts, record)
    local msg = record["MESSAGE"] or ""
    msg = msg:gsub("\27%[[0-9;]*m", "")
    record["message_clean"] = msg

    for k, v in msg:gmatch("([%w_]+)=([%w%p]+)") do
        record[k] = v
    end

    record["time"] = msg:match("(%d+:%d+%a%a)")
    record["level"] = msg:match("%s(%u+)%s")
    record["event"] = msg:match("%u+%s([^\n]+)")
    record["node"] = "story-node"
    
    return 1, ts, record
end