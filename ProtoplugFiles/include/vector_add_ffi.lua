local ffi = require("ffi")

-- https://learn.microsoft.com/de-de/cpp/c-runtime-library/reference/aligned-malloc?view=msvc-170
-- NOTE: Right now this is only working for WINDOWS! Standard C has a different function for allocating/freeing aligned memory
ffi.cdef[[
	void *_aligned_malloc(size_t, size_t);
	void _aligned_free(void *);
	typedef double* aligned_double_ptr_t __attribute__ ((aligned (64)));
    void add_vectors       (const double* a, const double* b, double* result, size_t n);
    void square_vector     (const double* input,              double* result, size_t n);
    void compute_abs_ratio (const double* a, const double* b, double* result, size_t n);
    void squared_difference(const double* a, const double* b, double* result, size_t n);
    double* compute_rms_windowed(const double* input, size_t n, size_t window);

    double* allocate_aligned_memory(size_t n);
    void free_aligned_memory(double* ptr);
]]

local simdLib = ffi.load("vector_add")

local M = {}

-- https://forum.defold.com/t/luajit-ffi/77979
--ffi.metatype("aligned_buffer_t",{})
M._doubleSize           = ffi.sizeof("double")
M._maxSimdRegisters     = 4
M._memoryAlignmentBytes = 8

function M.simdRegisterPaddingSize(n)
    --
    -- align the size of the array to fit the number of parallel register slots
    -- registerPaggingModulo might be between 0 and           3 (given that maxRegisters = 4)
    local registerPaggingModulo = n % M._maxSimdRegisters    
    local simdPegisterPaddedN = n
    if registerPaggingModulo ~= 0 then
        -- only if there's a registerPaggingModulo add a padding
        simdPegisterPaddedN = simdPegisterPaddedN + M._maxSimdRegisters - (registerPaggingModulo)
    end
    return simdPegisterPaddedN
end
--
--  Create Memory Aligned Buffer for use by SIMD optimized functions
--  NOTES:
--  I first tried ffi.gc to tie memory ptr and a finalizer and return only the cdata ptr.
--  But it turns out that this will lead to too unexpected early gc, while the ptr is actually still in use.
--  Therefore the "native" pointer is wrapped in a LUA table AND only this table has the finalizer
--
--  The __gc metamethod is only supported on lua 5.2. Which would lead to another workaround described here:
--  https://stackoverflow.com/questions/27426704/lua-5-1-workaround-for-gc-metamethod-for-tables
--  but it seems Mike Pall has added __gc metamethod to luajit, readin this: https://github.com/LuaJIT/LuaJIT/issues/47
--
--  Returns:
--    { ptr = <double *> }, with bound __gc. Use <instance>:getPtr() on this table to get raw pointer 
--    paddedSize, i.e. the array size extended to a multiple of the number of slots of the simd registers (AVX2 = 4)
--
local function create_aligned_memory(n)
    --
    local simdPegisterPaddedN = M.simdRegisterPaddingSize(n)
	--
	-- first a gc finalizer that takes a cdata pointerand frees it
	local gcFct = function(ptr)
		print("!!!!!!!!!! GCC: "..tostring(ptr))
		ffi.C._aligned_free(ptr)
	end
    --
    -- get momory aligned pointer, i.e. align towards cache lines and add a gc finalizer function
	local memPtr     = ffi.C._aligned_malloc(simdPegisterPaddedN * M._doubleSize, M._memoryAlignmentBytes) 
    local castMemPtr = ffi.cast(
		"double*",
		memPtr
	)
    if castMemPtr == nil then
        error("Failed to allocate memory")
    end
	--
	-- prepare return values: A wrapper table with a __gc finalizer
	local resTableWithGC = { ptr=castMemPtr }
	function resTableWithGC:getPtr() return self.ptr end
	setmetatable(
		resTableWithGC,
		{
            __call = function(obj) return obj.ptr end,
			__gc = function(obj) gcFct(obj.ptr) end
		}
	)
	return resTableWithGC, simdPegisterPaddedN
end

function M.add_vectors_into(op1, op2, result, n)
    simdLib.add_vectors(op1(), op2(), result(), n)
    return result, n
end

function M.square_vector_into(input, result, n)
    simdLib.square_vector(input(), result(), n)
    return result, n
end

local _m_add_into = M.add_vectors_into
local _m_square_into = M.square_vector_into

function M.add_vectors(op1, op2, n)
    local result, paddedN = create_aligned_memory(n)
    return _m_add_into(op1, op2, result, paddedN)
end

function M.square_vector(input, n)
    local result, paddedN = create_aligned_memory(n)
    return _m_square_into(input, result, paddedN)
end

function M.compute_rms_windowed(input, n, window)
    local rms_values = simdLib.compute_rms_windowed(input(), n, window)
    local num_windows = math.ceil(n / window)
    local result_table = {}
    for i = 0, num_windows - 1 do
        result_table[i + 1] = rms_values[i]
    end
    return result_table
end

function M.compute_abs_ratio(a, b, result, n)
    simdLib.compute_abs_ratio(a, b, result, n)
    return result, n
end

function M.squared_difference(a, b, result, n)
    simdLib.squared_difference(a, b, result, n)
    return result, n
end

function M.allocate_aligned_memory(n)
    return create_aligned_memory(n)
end

return M