local base32 = {}

function base32.decode(lookup, input, mode)
	if mode == "string" or mode == nil then
		local buffer = {}
		local length = math.floor(#input*5/8)
		local bits = length*8 - #input*5
		local acc = 0
		local buffer_pointer = length
		for i=#input, 1, -1 do
			local word5 = lookup[input:byte(i)]
			if not word5 then
				return nil, "Invalid character: " .. tostring(input:sub(i, i))
			end
			word5 = word5 * 2^bits
			bits = bits + 5
			acc = acc + word5
			if bits >= 8 then
				local b256 = acc % 256
				acc = math.floor(acc/256)
				bits = bits - 8
				buffer[buffer_pointer] = string.char(b256)
				buffer_pointer = buffer_pointer-1
			end
		end
		return table.concat(buffer)
	elseif mode == "number" then
		local number = 0
		for i=1, #input do
			number = number * 32 + lookup[input:byte(i)]
		end
		return number
	else
		error("Cannot decode type, supported are 'string' (default) and 'number', got " .. mode)
	end
end

function base32.encode(lookup, binary, length)
	local buffer = {}
	if type(binary) == "string" then
		local length = math.ceil(#binary*8/5)
		local acc = 0
		local bits = length*5 - #binary*8
		local buffer_pointer = length
		for i=#binary, 1, -1 do
			local byte = binary:byte(i)
			acc = acc + byte * 2^bits
			bits = bits + 8
			while bits >=5 do
				local b32 = (acc % 32)+1
				acc = math.floor(acc / 32)
				bits = bits - 5
				buffer[buffer_pointer] = lookup:sub(b32, b32)
				buffer_pointer = buffer_pointer-1
			end
		end
	elseif type(binary) == "number" then
		length = length or math.floor(math.log(binary, 32))+1
		for i=length, 1, -1 do
			local modulo = binary % 32
			buffer[i] = lookup:sub(modulo + 1, modulo + 1)
			binary = (binary - modulo) / 32
		end
	else
		error("Cannot encode type, supported are 'string' and 'number', got " .. type(binary))
	end
	return table.concat(buffer)
end

return base32
