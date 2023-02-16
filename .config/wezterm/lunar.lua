-- taken from
-- https://github.com/LunarVim/lunar.nvim/blob/master/lua/lunar/palette.lua

local colors = {
    fg = "#c0caf5",
    bg = "#1a1b26",
    bg_dark = "#16161e",
    bg_highlight = "#292e42",
    terminal_black = "#414868",
    fg_dark = "#a9b1d6",
    fg_gutter = "#3b4261",
    dark3 = "#545c7e",
    comment = "#565f89",
    dark5 = "#737aa2",
    blue0 = "#3d59a1",
    blue = "#7aa2f7",
    cyan = "#7dcfff",
    blue1 = "#2ac3de",
    blue2 = "#0db9d7",
    blue5 = "#89ddff",
    blue6 = "#b4f9f8",
    blue7 = "#394b70",
    magenta = "#bb9af7",
    magenta2 = "#ff007c",
    purple = "#9d7cd8",
    orange = "#ff9e64",
    yellow = "#e0af68",
    green = "#9ece6a",
    green1 = "#73daca",
    green2 = "#41a6b5",
    teal = "#1abc9c",
    red = "#f7768e",
    red1 = "#db4b4b",
    git_change = "#6183bb",
    git_add = "#449dab",
    git_delete = "#914c54",
    gitsigns_add = "#266d6a",
    gitsigns_change = "#536c9e",
    gitsigns_delete = "#b2555b",
    diff_add = "#41a6b5",
    diff_change = "#394b70",
    diff_delete = "#db4b4b",
    diff_text = "#394b70",
    gitignore = "#545c7e",
    border_highlight = "#3d59a1",
    bg_popup = "#16161e",
    bg_statusline = "#16161e",
    float_bg = "#16161e",
    bg_visual = "#2d59a1",
    bg_search = "#3d59a1",
    fg_sidebar = "#a9b1d6",
    black = "#000000",
    border = "#000000",
    error = "#db4b4b",
    warning = "#e0af68",
    info = "#0db9d7",
    hint = "#1abc9c",
}

local lunar = {
    foreground = colors.fg,
    background = colors.bg,
    cursor_bg = colors.fg,
    cursor_fg = colors.bg,
    cursor_border = colors.fg,
    ansi = {
        colors.dark3,
        colors.red1,
        colors.green2,
        colors.yellow,
        colors.cyan,
        colors.purple,
        colors.blue2,
        colors.fg_dark,
    },
    brights = {
        colors.dark5,
        colors.red,
        colors.green1,
        colors.orange,
        colors.blue5,
        colors.magenta,
        colors.blue1,
        colors.fg,
    },
}

return lunar
