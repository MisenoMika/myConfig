" ============================
" 基础设置
" ============================
set nocompatible            " 关闭兼容模式，使用 Vim 的增强功能
filetype plugin indent on   " 自动识别文件类型并加载对应插件和缩进
syntax on                   " 开启语法高亮
set encoding=utf-8          " 文件编码
set backspace=indent,eol,start

" ============================
" 界面设置
" ============================
set number                  " 显示行号
set cursorline              " 高亮当前行
set showmatch               " 高亮匹配括号
set ruler                   " 显示光标位置
set laststatus=2            " 总是显示状态栏
set showcmd                 " 显示命令
set wildmenu                " 命令行补全增强
set lazyredraw              " 绘制优化

" ============================
" 搜索设置
" ============================
set ignorecase              " 搜索不区分大小写
set smartcase               " 如果包含大写则区分大小写
set incsearch               " 边输入边搜索
set hlsearch                " 高亮搜索结果

" ============================
" 缩进和制表符
" ============================
set tabstop=4               " 一个 Tab 占 4 个空格
set shiftwidth=4            " >> << 操作移动 4 个空格
set expandtab               " Tab 转为空格
set autoindent              " 自动缩进
set smartindent             " 智能缩进
set softtabstop=4

" ============================
" 剪贴板
" ============================
set clipboard=unnamedplus   " 使用系统剪贴板

" ============================
" 视觉效果
" ============================
colorscheme desert          " 主题，可改为自己喜欢的，比如: 'gruvbox', 'molokai'
set background=dark         " 背景深色
set showtabline=2           " 总是显示标签栏
set signcolumn=yes          " 始终显示符号列（方便 lint 或 git）

" ============================
" 状态栏
" ============================
set statusline=%f\ %y\ %m\ %r\ %=Line:%l/%L\ Col:%c

" ============================
" 快捷键
" ============================
" 保存/退出
nnoremap <C-s> :w<CR>
nnoremap <C-q> :q<CR>

" 窗口操作
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" 复制粘贴
vnoremap <C-c> "+y
nnoremap <C-v> "+p



