-- Lua 5.1 mock suite for Dyre's Threat and Combat Tools. Run from the
-- repository root:
--   lua5.1 tests/run.lua
-- Mocks cannot prove dragging, the settings panel, protected actions, secret
-- values, or taint in the client; TESTING.md lists the in-client checks.
--
-- Dyre's Toolkit's runtime files come from ../DyresToolkit when that checkout
-- is there, else from the copy in tests/toolkit (as in CI, which has only
-- this repository). Set DCT_TOOLKIT=vendored to use the copy anyway.

if _VERSION ~= "Lua 5.1" then
    io.stderr:write("This suite requires Lua 5.1; found " .. tostring(_VERSION) .. "\n")
    os.exit(1)
end

local tests = {}

local function test(name, body)
    tests[#tests + 1] = {name = name, body = body}
end

local function equal(actual, expected, context)
    if actual ~= expected then
        error((context and context .. ": " or "") .. "expected " .. tostring(expected) .. ", got "
            .. tostring(actual), 2)
    end
end

local function contains(text, fragment, context)
    if type(text) ~= "string" or not text:find(fragment, 1, true) then
        error((context and context .. ": " or "") .. "expected text containing " .. tostring(fragment)
            .. ", got " .. tostring(text), 2)
    end
end

local function ToolkitFolder()
    if os.getenv("DCT_TOOLKIT") ~= "vendored" then
        local probe = io.open("../DyresToolkit/Core.lua", "rb")
        if probe then
            probe:close()
            return "../DyresToolkit/"
        end
    end
    return "tests/toolkit/"
end
local TOOLKIT_FOLDER = ToolkitFolder()
print("Dyre's Toolkit from " .. TOOLKIT_FOLDER)

-- The threat labels, tank tools, and Pet Taunt warning (moved from Dyre's
-- Toolkit), with their client harness.
local fixture = assert(loadfile("tests/tank.lua"))(test, equal, contains, TOOLKIT_FOLDER)
-- The swing timer and range box: the same harness.
assert(loadfile("tests/swing.lua"))(test, equal, contains, fixture)
-- DCT's own: the gate, the one-time copy from the Toolkit, the package.
assert(loadfile("tests/dct.lua"))(test, equal, contains, fixture)

local failed = 0
for index, entry in ipairs(tests) do
    local ok, message = xpcall(entry.body, debug.traceback)
    if ok then
        print("ok " .. index .. " - " .. entry.name)
    else
        failed = failed + 1
        print("not ok " .. index .. " - " .. entry.name)
        print(message)
    end
end
print("")
print(#tests .. " tests: " .. (#tests - failed) .. " passed, " .. failed .. " failed")
print("Mock results do not establish in-client compatibility.")
if failed > 0 then
    os.exit(1)
end
