-- This module provides an interface to Neovim's statusline generator using LuaJIT FFI

-- Since LuaJIT FFI doesn't work properly on Windows when referring to Neovim internals,
-- return dummy functions instead on Windows.
if vim.fn.has('win32') then
    return {
        get_statusline_expr_width = function(_)
            return 0
        end
    }
end

local M = {}

local ffi = require('ffi')

-- Definitions required to use Neovim's build_stl_str_hl function to expand statusline expressions
ffi.cdef [[
typedef unsigned char char_u;
typedef struct window_S win_T;
typedef struct {} stl_hlrec_t;
typedef struct {} StlClickRecord;

extern win_T *curwin;

int build_stl_str_hl(
    win_T *wp,
    char_u *out,
    size_t outlen,
    char_u *fmt,
    int use_sandbox,
    char_u fillchar,
    int maxwidth,
    stl_hlrec_t **hltab,
    StlClickRecord **tabtab
);
]]

-- Used CType values stored in a local variable to avoid redefining them and improve performance
local char_u_str_t = ffi.typeof('char_u*')

-- Statusline string buffer
local stlbuf_len = 1024
local stlbuf = ffi.new('char_u[?]', stlbuf_len)

-- Get display width of statusline expression
function M.get_statusline_expr_width(expr)
    return ffi.C.build_stl_str_hl(
        ffi.C.curwin,
        stlbuf,
        stlbuf_len,
        ffi.cast(char_u_str_t, expr),
        0,
        0,
        0,
        nil,
        nil
    )
end

return M
