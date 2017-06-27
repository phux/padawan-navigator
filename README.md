# PHP code navigation in Neovim

WIP: Neovim plugin for providing code navigation by using [padawan.php](https://github.com/padawan-php/padawan.php).

## Try it

Install padawan.php
```
git clone https://github.com/phux/padawan.php.git ~/padawan.php
cd ~/padawan.php
git checkout code-navigator
composer install
```

In init.vim:
```
Plug 'phux/padawan-navigator', {'do': ':UpdateRemotePlugins'}

let g:padawan_navigator#server_command='~/padawan.php/bin/padawan-server'

nnoremap <leader>pp :call PadawanGetParents()<cr>
nnoremap <leader>pi :call PadawanGetImplementations()<cr>
nnoremap <leader>pc :call padawan_navigator#CloseWindow()<cr>
```

## Todo

* list parents (classes & interfaces) of current file - done
* list implementing classes/interfaces of current file - done
* push to taglist - currently only opening files, not jumping to tags
* `PadawanGetImplementations()` doesn't work for vendor files
