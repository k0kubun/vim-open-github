# vim-open-github

NOTE: This is no longer maintained in favor of [tyru/open-browser-github.vim](https://github.com/tyru/open-browser-github.vim).
Please use its `:OpenGithubFile`.

## Description

Quickly open your current buffer in GitHub.
This plugin is a forked version of [vim-to-github](https://github.com/tonchis/vim-to-github) with a support of flexible remote path, such as GitHub Enterprise.

![](http://i.gyazo.com/0473edc2f72f1e8bf8b4111023a9993b.gif)

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

No need to copy browser's address bar.

### Specify branch, tag or revision

```
:OpenGithub v4.2.3
```

You can specify the revision to open.

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
