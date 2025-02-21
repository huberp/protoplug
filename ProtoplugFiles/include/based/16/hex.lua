--- Implements Hexadecimal encoding

local hex = {}

--- Decodes a single byte from a hex string
-- @tparam string byte A single character representing the byte to encode
-- @treturn string Input byte as a hex-encoded string of length 2
local function encode(char)
	return string.format('%02x', char:byte())
end

--- Encodes a string of binary data into hex
-- @tparam string data Input binary data
-- @treturn string Encoded hex data
function hex.encode(data)
	return (data:gsub(".", encode))
end

--- Decodes a single byte from a hex string
-- @tparam string byte Input byte as a hex-encoded string of length 2
-- @treturn string A single character representing the decoded byte
local function decode(byte)
	return string.char(tonumber(byte, 16))
end

--- Decodes a string of hex-encoded binary data
-- @tparam string data Input hex data
-- @treturn string Decoded binary data
function hex.decode(data)
	return (data:gsub("%x%x", decode))
end

return hex
