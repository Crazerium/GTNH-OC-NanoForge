local component = require("component")

local lines = {}

local function log(message, show)
  message = tostring(message)
  lines[#lines + 1] = message
  if show ~= false then
    print(message)
  end
end

local function sortedKeys(map)
  local keys = {}
  for key in pairs(map) do
    keys[#keys + 1] = tostring(key)
  end
  table.sort(keys)
  return keys
end

local function matchesMethod(name)
  local lower = name:lower()
  local fragments = {
    "fluid", "tank", "network", "redstone", "recipe",
    "progress", "working", "active", "transfer", "inventory",
    "input", "output", "craft", "machine", "energy", "stored"
  }
  for _, fragment in ipairs(fragments) do
    if lower:find(fragment, 1, true) then
      return true
    end
  end
  return false
end

local function fluidDisplay(fluid)
  if type(fluid) ~= "table" then
    return tostring(fluid), "unknown"
  end
  local nested = type(fluid.fluid) == "table" and fluid.fluid or {}
  local name = fluid.label or fluid.name or fluid.fluidName
    or nested.label or nested.name or fluid.fluid or "unknown"
  local amount = fluid.amount or fluid.size or fluid.qty
    or nested.amount or "unknown"
  return tostring(name), tostring(amount)
end

local function probeFluids(address)
  local ok, result = pcall(component.invoke, address, "getFluidsInNetwork")
  if not ok then
    log("  ME fluid query failed: " .. tostring(result))
    return
  end
  if type(result) ~= "table" then
    log("  ME fluid query returned: " .. tostring(result))
    return
  end

  local count = 0
  local found = 0
  local samples = {}
  for _, fluid in pairs(result) do
    count = count + 1
    local name, amount = fluidDisplay(fluid)
    local lower = name:lower()
    if lower:find("magmatter", 1, true) or lower:find("mag_matter", 1, true) then
      found = found + 1
      log("  MAGMATTER: " .. name .. " | reported amount: " .. amount)
    elseif #samples < 5 then
      samples[#samples + 1] = name .. " (" .. amount .. ")"
    end
  end
  log("  ME fluids returned: " .. count .. "; Magmatter entries: " .. found)
  if found == 0 then
    log("  Sample fluids: " .. (#samples > 0 and table.concat(samples, "; ") or "(none)"))
  end
  log("  Amount units are not assumed; verify against the ME terminal.")
end

local ignored = {
  computer = true,
  gpu = true,
  screen = true,
  keyboard = true,
  eeprom = true,
  filesystem = true,
  internet = true,
  disk_drive = true
}

log("GTNH OC NanoForge component probe")
log("Read-only scan. No machine or fluid transfers.")
log("")

local total = 0
local inspected = 0
local meReaders = 0

for address, kind in component.list() do
  total = total + 1
  log("[" .. total .. "] " .. kind .. " | " .. address)
  if not ignored[kind] then
    inspected = inspected + 1
    local ok, methods = pcall(component.methods, address)
    if ok and type(methods) == "table" then
      local names = sortedKeys(methods)
      local relevant = {}
      for _, name in ipairs(names) do
        if matchesMethod(name) then
          relevant[#relevant + 1] = name
        end
      end
      log("  All methods: " .. table.concat(names, ", "), false)
      log("  Relevant: " .. (#relevant > 0 and table.concat(relevant, ", ") or "(none)"))
      if methods.getFluidsInNetwork ~= nil then
        meReaders = meReaders + 1
        probeFluids(address)
      end
    else
      log("  Cannot inspect methods: " .. tostring(methods))
    end
  end
end

log("")
log("Components: " .. total .. " | inspected: " .. inspected
  .. " | ME fluid readers: " .. meReaders)

local path = "/home/probe.log"
local file, err = io.open(path, "w")
if file then
  file:write(table.concat(lines, "\n"), "\n")
  file:close()
  print("Saved full report: " .. path)
else
  print("Could not save report: " .. tostring(err))
end
