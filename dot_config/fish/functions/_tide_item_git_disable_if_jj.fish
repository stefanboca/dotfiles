function _tide_item_git_disable_if_jj
    command -q jj && jj --ignore-working-copy root &>/dev/null && return 1

    _tide_item_git
end
