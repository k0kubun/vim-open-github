# vim-open-github

Quickly open your current lines in GitHub.
This plugin is forked version of [vim-to-github](https://github.com/tonchis/vim-to-github) with a support of flexible remote path, such as GitHub Enterprise.

## Usage

### Basic

```
:OpenGithub
```

Will load origin's host and open current buffer's file in GitHub.

### Highlight lines

```
:'<,'>OpenGithub
```

Visual mode is supported.

## Installation

Example for [neobundle.vim](https://github.com/Shougo/neobundle.vim)

```vim
NeoBundle 'k0kubun/vim-open-github'
```

## Thanks

- To [tonchis/vim-to-github](https://github.com/tonchis/vim-to-github) for original version

## License

MIT License
