#!/bin/sh
set -e


### HELPER METHODS ###

command_exists () {
  type "$1" &> /dev/null ;
}

install_via_github_app () {
  if ! [ -a /Applications/GitHub.app ]; then
    echo "Downloading GitHub app..."
    curl -o ~/Downloads/GitHubForMac.zip -L https://central.github.com/mac/latest
    unzip ~/Downloads/GitHubForMac.zip -d /Applications/
    echo "...done."
  fi

  echo "Opening GitHub app. Once open,\n1. Open 'GitHub' menu in the top left\n2. Click 'Preferences...'\n3. Click 'Advanced' tab\n4. Click 'Install Command Line Tools'"
  read -p "Press ENTER to continue. > "
  open /Applications/GitHub.app
  read -p "Press ENTER when done. > "
}

install_git () {
  if command_exists xcode-select; then
    echo "Installing command-line tools..."
    xcode-select --install
    echo "...done."
  elif which apt-get; then
    apt-get install git
  elif which yum; then
    yum install git
  else
    install_via_github_app
  fi

  # re-check for Git
  if command_exists git; then
    echo "$(git --version) successfully installed."
  else
    echo "Git failed to install. Please try again, or open an issue at https://github.com/afeld/git-setup/issues."
    exit 1
  fi
}

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

is_mac () {
  if [ "$(uname -s)" == "Darwin" ]; then
    return 0
  else
    return 1
  fi
}

install_keychain_credential_helper () {
  echo "Installing OSX keychain credential helper..."
  curl -o ~/Downloads/git-credential-osxkeychain -s https://github-media-downloads.s3.amazonaws.com/osx/git-credential-osxkeychain
  chmod u+x ~/Downloads/git-credential-osxkeychain
  sudo mv ~/Downloads/git-credential-osxkeychain "$(dirname $(which git))/git-credential-osxkeychain"
  config_unless_set credential.helper osxkeychain
  echo "...done."
}

######################


# check if Git is installed
if command_exists git; then
  # TODO check that version is >= 1.7.10 (for autocrlf and credential helper)
  echo "$(git --version) already installed."
else
  install_git
fi


# set up credentials
if is_mac; then
  if command_exists git-credential-osxkeychain; then
    echo "OSX keychain credential helper already installed."
  else
    install_keychain_credential_helper
  fi

  # force HTTPS
  # via https://coderwall.com/p/sitezg
  config_unless_set url."https://github.com".insteadOf git://github.com
else
  # TODO set up SSH for them
  read -p "Set up SSH keys – see https://help.github.com/articles/generating-ssh-keys. Press ENTER when done. > "
fi


echo "Setting configuration..."

# user-specified settings
prompt_unless_set user.name "What's your full name?"
prompt_unless_set user.email "What's your email?"

# recommended defaults
config_unless_set branch.autosetupmerge true
config_unless_set color.ui true
config_unless_set core.autocrlf input
config_unless_set push.default upstream

echo "...done."


# TODO set up global .gitignore


# TODO add credential helper


echo "Complete!"
