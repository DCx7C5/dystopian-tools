# shellcheck shell=sh
# shellcheck disable=SC2001

# Set secure umask for all temporary file operations in this library
umask 077

set_github_token() {
  temp_file=$(mktemp "$DA_DIR/${DA_DB}.XXXXXXX") || {
    echoe "Failed creating temporary database file"
    return 1
  }

  jq -e --arg val "$1" '.GITHUB_TOKEN = $val' -- "$DA_DB" > "$temp_file" || {
    echoe "Failed setting value for GITHUB_TOKEN"
    return 1
  }

  mv -- "$temp_file" "$DA_DB" || {
    echoe "Failed moving temporary database file"
    rm -f -- "$temp_file"
    return 1
  }
  return 0
}

get_github_token() {
  jq -r '.GITHUB_TOKEN // empty' -- "$DA_DB" || {
    echoe "Failed getting GITHUB_TOKEN"
    return 1
  }
  return 0
}

set_package_value() {
  temp_file=$(mktemp "$DA_DIR/${DA_DB}.XXXXXXX") || {
    echoe "Failed creating temporary database file"
    return 1
  }

  jq -e --arg idx "$1" \
        --arg key "$2" \
        --arg val "$3" \
        '.packages[$idx][$key] = $val' -- "$DA_DB" > "$temp_file" || {
          echoe "Failed setting package key & value"
          return 1
        }

  mv -- "$temp_file" "$DA_DB" || {
    echoe "Failed moving temporary database file"
    rm -f -- "$temp_file"
    return 1
  }

  return 0
}

get_package_value() {
  jq -r --arg idx "$1" \
        --arg key "$2" \
        '.packages[$idx][$key] // empty' -- "$DA_DB" || {
          echoe "Failed getting package value"
          return 1
        }
  return 0
}
