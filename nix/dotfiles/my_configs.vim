set clipboard=unnamed
let g:NERDTreeWinPos = "left"
set clipboard=unnamedplus
set number

if !isdirectory(expand('~/.vim/undodir'))
    call mkdir(expand('~/.vim/undodir'), 'p')
endif
set undodir=~/.vim/undodir
set undofile
