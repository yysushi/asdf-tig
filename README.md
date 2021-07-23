<div align="center">

# asdf-tig [![Build](https://github.com/koketani/asdf-tig/actions/workflows/build.yml/badge.svg)](https://github.com/koketani/asdf-tig/actions/workflows/build.yml) [![Lint](https://github.com/koketani/asdf-tig/actions/workflows/lint.yml/badge.svg)](https://github.com/koketani/asdf-tig/actions/workflows/lint.yml)


[tig](https://jonas.github.io/tig/) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Why?](#why)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, `tar`: generic POSIX utilities.
- `SOME_ENV_VAR`: set this environment variable in your shell config to load the correct version of tool x.

# Install

Plugin:

```shell
asdf plugin add tig https://github.com/koketani/asdf-tig.git
```

tig:

```shell
# Show all installable versions
asdf list-all tig

# Install specific version
asdf install tig latest

# Set a version globally (on your ~/.tool-versions file)
asdf global tig latest

# Now tig commands are available
tig --help
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/koketani/asdf-tig/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [koketani](https://github.com/koketani/)
