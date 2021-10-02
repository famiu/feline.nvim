-- This module provides an interface to Neovim's statusline generator using Lua FFI
local M = {}

local ffi = require('ffi')

-- Definitions required to use Neovim's build_stl_str_hl function to expand statusline expressions
-- And also other definitions used by this module
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
local char_u_buf_t = ffi.typeof('char_u[?]')
local char_u_str_t = ffi.typeof('char_u*')

-- Statusline string buffer
local stlbuf = char_u_buf_t(256)
local stlbuf_len = 256

-- Expand statusline expression, returns a Lua string containing plaintext with only the characters
-- that'll be displayed in the statusline
function M.expand_statusline_expr(expr)
    ffi.C.build_stl_str_hl(
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

    return ffi.string(stlbuf)
end

-- Get display width of statusline expression
function M.get_statusline_expr_width(expr)
    return tonumber(ffi.C.build_stl_str_hl(
        ffi.C.curwin,
        stlbuf,
        stlbuf_len,
        ffi.cast(char_u_str_t, expr),
        0,
        0,
        0,
        nil,
        nil
    ))
end

return M


