# shellcheck shell=sh
# shellcheck disable=SC2001

set_default_host() {
  jq -e --arg val "$1" '.defaultHost = $val' -- "$DH_DB" > "$DH_DB.tmp" || {
    rm -f -- "$DH_DB.tmp"
    return 1
  }

  mv -- "${DH_DB}.tmp" "$DH_DB" || {
    echoe "Failed moving $DH_DB"
    rm -f -- "$DH_DB.tmp"
    return 1
  }

  rm -f -- "${DH_DB}.tmp" || {
    echoe "Removing $DC_DB.tmp failed"
    rm -f -- "$DC_DB.tmp"
    return 1
  }

  return 0
}

get_default_host() {
  jq -r '.defaultHost // empty' -- "$DH_DB" || return 1
}

set_host_value() {
  if [ "$#" -eq 3 ]; then
    jq -e --arg idx "$1" \
          --arg key "$2" \
          --arg val "$3" \
          '.hosts[$idx][$key] = $val' -- "$DH_DB" > "$DH_DB.tmp" || {
            echoe "Failed setting $2 = $3 at $1"
            rm -f -- "$DH_DB.tmp"
            return 1
          }
  elif [ "$#" -eq 1 ]; then
    jq -e --arg idx "$1" \
          '.hosts[$idx] = {}' -- "$DH_DB" > "$DH_DB.tmp" || {
            echoe "Failed creating new host index: $1"
            rm -f -- "$DH_DB.tmp"
            return 1
          }
  else
    return 1
  fi

  mv -- "${DH_DB}.tmp" "$DH_DB" || {
    echoe "Failed moving $DH_DB"
    rm -f -- "$DH_DB.tmp"
    return 1
  }

  rm -f -- "${DH_DB}.tmp" || {
    echoe "Removing $DH_DB.tmp failed"
    rm -f -- "$DH_DB.tmp"
    return 1
  }
  return 0
}

get_host_value() {
  jq -e --arg idx "$1" \
        --arg key "$2" \
        '.hosts[$idx][$key]' -- "$DH_DB" || return 1
}

