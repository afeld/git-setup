#!/bin/sh
set -e


# check if Git is installed
if [ -n "$(git --version)" ]; then
  echo "Git already installed."
else
  echo "Installing command-line tools..."
  # TODO handle OSes other than Mavericks
  xcode-select --install
fi


# usage:
#   is_set PROPERTY
is_set () {
  git config --global --get $1
}

# usage:
#   config_unless_set PROPERTY VALUE
config_unless_set () {
  if [ -z "$(is_set $1)" ]; then
    git config --global --add $1 $2
  fi
}

# usage:
#   prompt_unless_set PROPERTY PROMPT
prompt_unless_set () {
  if [ -z "$(is_set $1)" ]; then
    read -p "$2 > " VAL
    git config --global --add $1 $VAL
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
