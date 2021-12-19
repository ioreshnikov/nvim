" Bootstrapping
" -------------

" The section below automatically installs a plugin management system (in our
" case `vim-plug`) if it's not present in the system already. This means that
" we can copy this config on a clean machine, load nevim and then simply call
" :PlugInstall and have a working configuration.
let sitedir = stdpath('data') . '/site'
let vimplug = sitedir . '/autoload/plug.vim'

if empty(glob(vimplug))
silent execute
    \ '!curl -fLo ' . vimplug .
    \ ' --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


" Plugins
" -------

" The section below imports all the plugin needed by the configuration.
let plugdir = stdpath('data') . '/plugged'
call plug#begin(plugdir)

Plug 'junegunn/vim-plug'

call plug#end()
