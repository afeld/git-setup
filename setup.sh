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
  if command_exists brew; then
    echo "Installing Git via Homebrew..."
    brew update
    brew install git
    echo "...done."
  elif command_exists xcode-select; then
    echo "Installing command-line tools..."
    xcode-select --install
    echo "...done."
  elif which apt-get; then
    echo "Installing Git via apt-get..."
    sudo apt-get update
    sudo apt-get install git
    echo "...done."
  elif which yum; then
    echo "Installing Git via Yum..."
    yum install git
    echo "...done."
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
  echo "Installing OSX keychain credential helper (you may be prompted for your computer password)..."
  curl -o ~/Downloads/git-credential-osxkeychain -s https://github-media-downloads.s3.amazonaws.com/osx/git-credential-osxkeychain
  chmod u+x ~/Downloads/git-credential-osxkeychain
  sudo mv ~/Downloads/git-credential-osxkeychain "$(dirname $(which git))/git-credential-osxkeychain"
  config_unless_set credential.helper osxkeychain
  echo "...done."
}

set_up_https_only () {
  if command_exists git-credential-osxkeychain; then
    echo "OSX keychain credential helper already installed."
  else
    install_keychain_credential_helper
  fi

  # force HTTPS
  # via https://coderwall.com/p/sitezg
  config_unless_set url."https://github.com".insteadOf git://github.com
}

can_ssh_to_github () {
  ssh -o ConnectTimeout=5 -T git@github.com 2>&1 | grep successful
}

create_ssh_key () {
  echo "Creating SSH key..."
  EMAIL="$(git config --global --get user.email)"
  ssh-keygen -t rsa -C $EMAIL
  ssh-add ~/.ssh/id_rsa
  echo "...done."
}

add_ssh_key_to_github () {
  echo "1. Copy the following:\n"
  cat ~/.ssh/id_rsa.pub
  echo "\n2. Go to https://github.com/settings/ssh\n3. Click 'Add SSH key'\n4. Set the title to the name of your computer\n5. Paste the long string from above into the 'Key' field.\n6. Click 'Add key'\n"
  read -p "Press ENTER when done. > "

  if can_ssh_to_github; then
    echo "GitHub SSH set up successfully."
  else
    echo "Failed to set up SSH. See https://help.github.com/articles/generating-ssh-keys#step-4-test-everything-out for troubleshooting help."
    exit 1
  fi
}

set_up_ssh () {
  if [ -a ~/.ssh/id_rsa ]; then
    echo "SSH key already exists."
  else
    create_ssh_key
  fi

  add_ssh_key_to_github
}

set_recommended_defaults () {
  # see http://git-scm.com/docs/git-config for descriptions
  echo "Setting recommended defaults..."
  config_unless_set branch.autosetupmerge true
  config_unless_set color.ui true
  config_unless_set core.autocrlf input
  config_unless_set push.default simple
  echo "...done."
}

######################
#### INSTALLATION ####

# check if Git is installed
if command_exists git; then
  # TODO check that version is >= 1.7.10 (for autocrlf and credential helper)
  echo "$(git --version) already installed."
else
  install_git
fi


# user-specified settings
prompt_unless_set user.name "What's your full name?"
prompt_unless_set user.email "What's your email?"


# set up credentials
if is_mac; then
  set_up_https_only
elif ! can_ssh_to_github; then
  set_up_ssh
fi


set_recommended_defaults


# TODO set up global .gitignore


echo "Complete!"
