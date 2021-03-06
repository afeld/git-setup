# Git Setup Script

Helps install and/or configure Git with good default settings, including:

* User information
* Simple branching
* Colors for command-line output
* Cross-platform line-ending compatibility

The script is safe to run even if you already have Git installed or have some of these settings in place already... it will only add those not previously set.

## Installation

Currently **only Mac and Linux** are supported. To execute, run this from your Terminal:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/afeld/git-setup/master/setup.sh)
```

### Debugging

**If you run into problems**, run

```bash
uname -a
ssh -V
curl --version
openssl version
DEBUG=1 bash <(curl -fsSL https://raw.githubusercontent.com/afeld/git-setup/master/setup.sh)
```

and paste the output into a [new issue](https://github.com/afeld/git-setup/issues/new).

### Windows

For Windows setup, try [GitHub for Windows](http://windows.github.com/), which comes preconfigured with all of the fixes in git-setup. Alternatives:

* [The official installer](http://git-scm.com/downloads) (a.k.a. [mysysGit](http://msysgit.github.io/)
* [Git Portable](https://github.com/bungeshea/GitPortable)
* [More info](http://git-scm.com/book/en/v2/Getting-Started-Installing-Git#Installing-on-Windows)

## Resources

See other useful development environment setup projects:

* https://github.com/github/gitignore
* http://dotfiles.github.io/
* https://github.com/afeld/git-plugins
* http://hub.github.com/
