"          cscope tuning
" ----------------------------------
set cscopequickfix=s-,c-,d-,i-,t-,e-
set cscopetag
set exrc
set csto=0
set cst
silent! map <unique> <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
silent! map <unique> <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
silent! map <unique> <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>
silent! map <unique> <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
silent! map <unique> <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
silent! map <unique> <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
silent! map <unique> <C-\>f :cs find f <C-R>=expand("<cword>")<CR><CR>
silent! map <unique> <C-\>i :cs find i <C-R>=expand("<cword>")<CR><CR>

"       restore position in file
" -----------------------------------
set viminfo='10,\"100,:20,%,n~/.viminfo
au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif

"      kernel coding style
" -----------------------------------
set formatoptions=croql
set cino=t0,:0,(0,)100,*100
set cindent sm wm=0 tw=0
set cindent sm wm=0 tw=0
set comments=sr:/*,mb:*,ex:*/,://
let c_space_errors=1

"  show trailing tabs, spaces, etc
" -----------------------------------
" set list listchars=tab:\|_,trail:.

"        spaces instead of tabs
" -----------------------------------
"set ts=4
"set sts=4
"set et

" no auto identation (for languages)
" -----------------------------------
set noai

"      tab completion in cmdline
" -----------------------------------
set wildmode=list:longest
syntax on
