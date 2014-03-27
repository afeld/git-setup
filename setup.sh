set -e


# install command-line tools
# TODO handle OSes other than Mavericks
xcode-select --install


read -p "What's your full name? > " NAME
git config --global --add user.name $NAME

read -p "What's your email? > " EMAIL
git config --global --add user.email $NAME

# recommended defaults
git config --global --add branch.autosetupmerge true
git config --global --add color.ui true
git config --global --add core.autocrlf input
git config --global --add push.default upstream


# TODO global .gitignore


# TODO add credential helper
