# shellcheck shell=sh
# shellcheck disable=SC2001


set_owner_guid() {
  jq -e --arg val "$1" '.GUID = $val' -- "$DS_DB" > "$DS_DB.tmp" || {
    echoe "Failed setting GUID for $1"
    rm -f -- "$DS_DB.tmp"
    return 1
  }

  mv -- "${DS_DB}.tmp" "$DS_DB" || {
    echoe "Failed moving $DS_DB"
    rm -f -- "$DS_DB.tmp"
    return 1
  }

  rm -f -- "${DS_DB}.tmp" || {
    echoe "Removing $DS_DB.tmp failed"
    rm -f -- "$DS_DB.tmp"
    return 1
  }
  return 0
}

get_owner_guid() {
  jq -r '.GUID // empty' -- "$DS_DB" || return 1
}

set_key_guid() {
  jq -e --arg idx "$1" \
        --arg val "$2" \
        '.[$idx].GUID = $val' -- "$DS_DB" > "$DS_DB.tmp" || {
          echoe "Failed setting GUID for host $1"
          rm -f -- "$DS_DB.tmp"
          return 1
        }

  mv -- "${DS_DB}.tmp" "$DS_DB" || {
    echoe "Failed moving $DS_DB"
    rm -f -- "$DS_DB.tmp"
    return 1
  }

  rm -f -- "${DS_DB}.tmp" || {
    echoe "Removing $DS_DB.tmp failed"
    rm -f -- "DS_DB.tmp"
    return 1
  }
  return 0
}

get_key_guid() {
  jq -r --arg idx "$1" '.[$idx].GUID // empty' -- "$DS_DB" || return 1
}

set_key_value() {
  jq -e --arg idx "$1" \
        --arg key "$2" \
        --arg val "$3" \
        '.[$idx].key[$key] = $val' -- "$DS_DB" > "$DS_DB.tmp" || {
          echoe "Failed setting $2 = $3 for host $1"
          rm -f -- "$DS_DB.tmp"
          return 1
        }

  mv -- "${DS_DB}.tmp" "$DS_DB" || {
    echoe "Failed moving $DS_DB"
    rm -f -- "$DS_DB.tmp"
    return 1
  }

  rm -f -- "${DC_DB}.tmp" || {
    echoe "Removing $DC_DB.tmp failed"
    rm -f -- "$DC_DB.tmp"
    return 1
  }
  return 0
}

set_cert_value() {
  jq -e --arg idx "$1" \
        --arg key "$2" \
        --arg val "$3" \
        '.[$idx].cert[$key] = $val' -- "$DS_DB" > "$DS_DB.tmp" || {
          rm -f -- "$DS_DB.tmp"
          return 1
        }

  mv -- "${DS_DB}.tmp" "$DS_DB" || {
    echoe "Failed moving $DS_DB"
    rm -f -- "$DS_DB.tmp"
    return 1
  }

  rm -f -- "${DS_DB}.tmp" || {
    echoe "Removing $DS_DB.tmp failed"
    rm -f -- "$DS_DB.tmp"
    return 1
  }
  return 0
}

get_key_value() {
  jq -e --arg idx "$1" \
        --arg key "$2" \
        '.[$idx].key[$key] // empty' -- "$DS_DB" || return 1
}

get_cert_value() {
  jq -e --arg idx "$1" \
        --arg key "$2" \
        '.[$idx].cert[$key] // empty' -- "$DS_DB" || return 1
}
