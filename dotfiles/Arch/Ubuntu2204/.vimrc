" ============================
" 基础设置
" ============================
set nocompatible                  " 关闭 Vi 兼容模式
filetype plugin indent on         " 自动文件类型、插件和缩进
syntax on                         " 语法高亮
set encoding=utf-8

set shortmess+=I                  " 禁用启动欢迎界面
set hidden                        " 允许隐藏未保存 buffer
set backspace=indent,eol,start

" ============================
" 界面设置
" ============================
set number                        " 行号
" set relativenumber                " 相对行号
set cursorline                    " 当前行高亮
set ruler                         " 显示光标位置
set laststatus=2                  " 总是显示状态栏
set showcmd                       " 显示命令
set wildmenu                      " 命令补全菜单
set lazyredraw                    " 重绘优化
set showmatch                     " 匹配括号高亮
set signcolumn=yes                " 始终显示 sign 列
set showtabline=2                 " 始终显示 tab 栏

" ============================
" 搜索设置
" ============================
set ignorecase                    " 默认忽略大小写
set smartcase                     " 包含大写时区分大小写
set incsearch                     " 实时搜索
set hlsearch                      " 高亮搜索结果

" ============================
" 缩进
" ============================
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set autoindent
set smartindent

" ============================
" 剪贴板
" ============================
set clipboard=unnamedplus

" ============================
" 视觉
" ============================
set background=dark
colorscheme desert

" ============================
" 状态栏
" ============================
set statusline=%f\ %y\ %m\ %r\ %=Line:%l/%L\ Col:%c

" ============================
" 鼠标
" ============================
set mouse+=a

" ============================
" 常用快捷键
" ============================

" 快速退出 insert
inoremap jj <Esc>

" 保存 / 退出
nnoremap <C-s> :w<CR>
nnoremap <C-q> :q<CR>

" 窗口移动
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" 系统剪贴板复制
vnoremap <C-c> "+y
nnoremap <C-v> "+p

" ============================
" 防止坏习惯（Missing Semester 推荐）
" ============================

" 禁用 Ex 模式
" nmap Q <Nop>

" 禁用方向键（normal mode）
" nnoremap <Left>  :echoe "Use h"<CR>
" nnoremap <Right> :echoe "Use l"<CR>
" nnoremap <Up>    :echoe "Use k"<CR>
" nnoremap <Down>  :echoe "Use j"<CR>

" insert mode
" inoremap <Left>  <ESC>:echoe "Use h"<CR>
" inoremap <Right> <ESC>:echoe "Use l"<CR>
" inoremap <Up>    <ESC>:echoe "Use k"<CR>
" inoremap <Down>  <ESC>:echoe "Use j"<CR>

" ============================
" 关闭提示音
" ============================
set noerrorbells visualbell t_vb=
