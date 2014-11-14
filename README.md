# vim-open-github

Quickly open your current buffer in GitHub.
This plugin is forked version of [vim-to-github](https://github.com/tonchis/vim-to-github) with a support of flexible remote path, such as GitHub Enterprise.

![](http://gifzo.net/sh6p9TbL41.gif)

## Usage

### Basic

```
:OpenGithub
```

Will load origin's url and open current buffer's file in GitHub.

### Highlight lines

```
:'<,'>OpenGithub
```

Visual mode is supported.

### Copy to pasteboard

```
:'<,'>CopyGithub
```

No need to copy browser's address bar

## Installation

Example for [neobundle.vim](https://github.com/Shougo/neobundle.vim)

```vim
NeoBundle 'k0kubun/vim-open-github'
```

## Development
### Run tests

```bash
$ bundle
$ rake
```

### Embed Ruby code to vim script

```bash
$ rake embed
```

## Thanks

- To [tonchis/vim-to-github](https://github.com/tonchis/vim-to-github) for original version

## License

MIT License
