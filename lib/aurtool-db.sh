# shellcheck shell=sh
# shellcheck disable=SC2001

set_github_token() {
  jq -e --arg val "$1" '.GITHUB_TOKEN = $val' -- "$DA_DB" || return 1
}

get_github_token() {
  jq -r '.GITHUB_TOKEN // empty' -- "$DA_DB" || return 1
}

set_package_value() {
  jq -e --arg idx "$1" \
        --arg key "$2" \
        --arg val "$3" \
        '.packages[$idx][$key] = $val' -- "$DA_DB" || return 1
}

get_package_value() {
  jq -r --arg idx "$1" \
        --arg key "$2" \
        '.packages[$idx][$key] // empty' -- "$DA_DB" || return 1
}
