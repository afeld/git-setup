#!/bin/sh
set -e


# check if Git is installed
# TODO check that version is >= 1.7.10
if [ -n "$(git --version)" ]; then
  echo "Git already installed."
else
  echo "Installing command-line tools..."
  # TODO handle OSes other than Mavericks
  xcode-select --install
fi


# usage:
#   is_set PROPERTY
config_is_set () {
  OUTPUT=$(git config --global --get $1)
  if [ -n "$OUTPUT" ]; then
    echo "EXISTS: $1=$OUTPUT"
    return 0
  else
    return 1
  fi
}

set_config () {
  echo "NEW:    $1=$2"
  git config --global --add $1 $2
}

# usage:
#   config_unless_set PROPERTY VALUE
config_unless_set () {
  if ! config_is_set $1; then
    set_config $1 $2
  fi
}

# usage:
#   prompt_unless_set PROPERTY PROMPT
prompt_unless_set () {
  if ! config_is_set $1; then
    read -p "$2 > " VAL
    set_config $1 $VAL
  fi
}

# user-specified settings
prompt_unless_set user.name "What's your full name?"
prompt_unless_set user.email "What's your email?"

# recommended defaults
config_unless_set branch.autosetupmerge true
config_unless_set color.ui true
config_unless_set core.autocrlf input
config_unless_set push.default upstream


# TODO global .gitignore


# TODO add credential helper


echo "Complete!"
