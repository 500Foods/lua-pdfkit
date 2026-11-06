#!/usr/bin/env lua
-- test/smoke.lua -- the Lua programs against test/digests.txt. No Node.
--
--   lua test/smoke.lua
--   lua test/smoke.lua --digest <file.pdf>
--
-- The blanking is the three substitutions in test/comparepdf.sh, copied here
-- so a checkout can check the digests without qpdf. A digest from either path
-- has to agree. comparepdf.sh remains the definition used by test/compare.sh.

local ROOT do
    local source = debug.getinfo(1, "S").source
    if source:sub(1, 1) == "@" then
        source = source:sub(2)
    end
    local dir = source:match("^(.*)/") or "."
    ROOT = dir .. "/.."
end

local HEX32 = string.rep("%x", 32)
local ZEROS32 = string.rep("0", 32)

-- Same three length-preserving substitutions as test/comparepdf.sh.
local function normalise(data)
    data = data:gsub("%(D:%d%d%d%d%d%d%d%d%d%d%d%d%d%dZ%)", "(D:00000000000000Z)")
    data = data:gsub(
        "/ID %[<" .. HEX32 .. "> <" .. HEX32 .. ">]",
        "/ID [<" .. ZEROS32 .. "> <" .. ZEROS32 .. ">]"
    )
    data = data:gsub(
        "<xmp:CreateDate>%d%d%d%d%-%d%d%-%d%dT%d%d:%d%d:%d%dZ</xmp:CreateDate>",
        "<xmp:CreateDate>0000-00-00T00:00:00Z</xmp:CreateDate>"
    )
    return data
end

local function quote(text)
    return string.format("%q", text)
end

local function sha256_file(path)
    local pipe = assert(io.popen("sha256sum " .. quote(path)))
    local line = pipe:read("*a") or ""
    local closed, how, code = pipe:close()
    local hex = line:match("^(%x+)")
    if not closed or not hex then
        error("sha256sum failed"
            .. (how and (" (" .. how .. " " .. tostring(code) .. ")") or ""))
    end
    return hex
end

local function digest_of(path)
    local handle = assert(io.open(path, "rb"))
    local data = handle:read("a")
    handle:close()
    local normalised = normalise(data)

    local tmp = os.tmpname()
    local out = assert(io.open(tmp, "wb"))
    out:write(normalised)
    out:close()
    local ok, hex_or_err = pcall(sha256_file, tmp)
    os.remove(tmp)
    if not ok then
        error(hex_or_err)
    end
    return hex_or_err
end

local function program_for(name)
    return ROOT .. "/test/programs/" .. name .. ".lua"
end

local function load_digests(path)
    local rows = {}
    for line in assert(io.open(path)):lines() do
        if line:sub(1, 1) ~= "#" and line:match("%S") then
            local name, hex = line:match("^(%S+)%s+(%x+)$")
            if not name or #hex ~= 64 then
                error("bad digest line: " .. line)
            end
            rows[#rows + 1] = { name = name, hex = hex }
        end
    end
    return rows
end

if arg[1] == "--digest" then
    assert(arg[2], "usage: lua test/smoke.lua --digest <file.pdf>")
    io.write(digest_of(arg[2]), "\n")
    return
end

if arg[1] == "-h" or arg[1] == "--help" then
    print("usage: lua test/smoke.lua")
    print("       lua test/smoke.lua --digest <file.pdf>")
    return
end

local digests = load_digests(ROOT .. "/test/digests.txt")
local work = ROOT .. "/test/out/smoke"
os.execute("mkdir -p " .. quote(work))

local failed = 0
for _, row in ipairs(digests) do
    local program = program_for(row.name)
    local pdf = work .. "/" .. row.name .. ".pdf"
    local log = work .. "/" .. row.name .. ".log"
    local cmd = string.format(
        "lua %s %s >%s 2>&1",
        quote(program), quote(pdf), quote(log)
    )
    local ran = os.execute(cmd)
    if not ran then
        failed = failed + 1
        io.stderr:write("fail ", row.name, ": program exited non-zero\n")
        local logged = io.open(log)
        if logged then
            io.stderr:write(logged:read("a"))
            logged:close()
        end
    else
        local hex = digest_of(pdf)
        if hex ~= row.hex then
            failed = failed + 1
            io.stderr:write(
                "fail ", row.name, "\n  got  ", hex, "\n  want ", row.hex, "\n"
            )
        else
            print("ok  " .. row.name)
        end
    end
end

if failed > 0 then
    os.exit(1)
end
