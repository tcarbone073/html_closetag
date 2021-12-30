## HTML Closetag
A utility to automaticaly close HTML elements as well as handle some fancy indentation.

Inspiration drawn heavily from [vim-closetag](https://github.com/alvan/vim-closetag).

## Basic Usage
Pressing `<` will automatically append the closing carrot, `>` and move the cursor between the two.

The line will read
```vim
<|>
```
Now type some html
```vim
<head|>
```
Hit `Tab`, and you will get
```vim
<head>|</head>
```
Hit `Enter`, and you will get
```vim
<head>
    |
</head>
```

## Snap out of quotes
```vim
<a href="someurl|">
```
Hit `Tab`, and you will get
```vim
<a href="someurl"|>
```

## Attributes are ignored
Hit `Tab` again, and you will get
```vim
<a href="someurl">|</a>
```

## Unpaired elements are not closed
```vim
<br|>
```
Hit `Tab`, and you will get
```vim
<br>|
```

## Installation
Put `html_closetag.vim` in `~/.vim/plugin/`
