"=============================================================================
"        File: texmenuconf.vim
"      Author: Srinath Avadhanula <srinath@fastmail.fm>
" Description: 
" 
" Installation:
"  Last Change: ¶ro maj 08 12:00  2002 U
"         TODO:
"=============================================================================

" Paths, crucial for functions
let s:path = expand("<sfile>:p:h")
let s:up_path = substitute(s:path, "latex-suite", "", "")
let s:mainmenuname = 'Te&X-Suite.'

if g:Tex_NestPackagesMenu
	let g:Tex_PackagesMenuLocation = '81.10 '.s:mainmenuname.'&Packages.'
else
	let g:Tex_PackagesMenuLocation = '81.10 '.g:Tex_MenuPrefix.'Packages.'
endif

let g:Tex_TemplatesMenuLocation = '80.20 '.s:mainmenuname.'&Templates.'
let g:Tex_MacrosMenuLocation = '80.20 '.s:mainmenuname.'&Macros.'

let g:Tex_EnvMenuLocation = '82.20 '.g:Tex_MenuPrefix.'Environments.'

if g:Tex_NestElementMenus
	let g:Tex_ElementsMenuLocation = '83.20 '.g:Tex_MenuPrefix.'Elements.'
else
	let g:Tex_ElementsMenuLocation = '83.20 '.g:Tex_MenuPrefix
endif

" Set up the compiler/viewer menus. {{{
"
if has('gui_running') && g:Tex_Menus
	anoremenu 80.25 Te&X-Suite.-sepsuite0-  :

	" menus for compiling / viewing etc.
	exec 'anoremenu 80.30 '.s:mainmenuname.'&Compile<tab>\\ll'.
		\'   :silent! call RunLaTeX()<CR>'
	exec 'anoremenu 80.40 '.s:mainmenuname.'&View<tab>\\lv'.
		\'   :silent! call ViewLaTeX()<CR>'
	exec 'anoremenu 80.50 '.s:mainmenuname.'&Search<tab>\\ls'.
		\'   :silent! call ForwardSearchLaTeX()<CR>'
	exec 'anoremenu 80.60 '.s:mainmenuname.'&Target\ Format<tab>:TTarget'.
		\'   :call SetTeXTarget()<CR>'
	exec 'anoremenu 80.70 '.s:mainmenuname.'&Compiler\ Target<tab>:TCTarget'.
		\'   :call SetTeXCompilerTarget("Compile", "")<CR>'
	exec 'anoremenu 80.80 '.s:mainmenuname.'&Viewer\ Target<tab>:TVTarget'.
		\'   :call SetTeXCompilerTarget("View", "")<CR>'
	exec 'anoremenu 80.90 '.s:mainmenuname.'Set\ &Ignore\ Level<tab>:TCLevel'.
		\'   :TCLevel NONE<CR>'
	exec 'anoremenu 80.100 '.s:mainmenuname.'-sepsuite1- :'
	" refreshing folds
	if g:Tex_Folding
		exec 'anoremenu 80.100 '.s:mainmenuname.'Refresh\ Folds<tab>\\rf'.
			\'   :call MakeTexFolds(1)<CR>'
		exec 'anoremenu 80.110 '.s:mainmenuname.'-sepsuite2- :'
	endif

	if filereadable(s:up_path.'tex/texrc')
		function! Tex_texrc()
			exec 'split '.s:up_path.'tex/texrc'
			lcd
		endfunction
		com! -nargs=0 TTexrc :call Tex_texrc()
		exec 'anoremenu 80.120 '.s:mainmenuname.'Edit\ &texrc<tab>:TexTexrc'.
			\' :TexTexrc<CR>'
	endif
endif

" }}}


" ==============================================================================
" MenuConf: configure the menus as compact/extended, with/without math
" ============================================================================== 
function! Tex_MenuConfigure(type, action) " {{{
	let menuloc = s:mainmenuname.'Configure\ Menu.'
	if a:type == 'math'
		if a:action == 1
			let g:Tex_MathMenus = 1
			exe 'so '.s:path.'/mathmacros.vim'
			exe 'amenu disable '.menuloc.'Add\ Math\ Menu'
			exe 'amenu enable '.menuloc.'Remove\ Math\ Menu'
		elseif a:action == 0
			call Tex_MathMenuRemove()
			exe 'amenu enable '.menuloc.'Add\ Math\ Menu'
			exe 'amenu disable '.menuloc.'Remove\ Math\ Menu'
		endif
	elseif a:type == 'elements'
		if a:action == 'expand'
			let g:Tex_ElementsMenuLocation = '80.20 '.g:Tex_MenuPrefix
			exe 'amenu disable '.menuloc.'Expand\ Elements'
			exe 'amenu enable '.menuloc.'Compress\ Elements'
		elseif a:action == 'nest'
			let g:Tex_ElementsMenuLocation = '80.20 '.g:Tex_MenuPrefix.'Elements.'
			exe 'amenu enable '.menuloc.'Expand\ Elements'
			exe 'amenu disable '.menuloc.'Compress\ Elements'
		endif
		exe 'source '.s:path.'/elementmacros.vim'
	elseif a:type == 'packages'
		if a:action == 1
			let g:Tex_PackagesMenu = 1
			exe 'so '.s:path.'/packages.vim'
			exe 'amenu disable '.menuloc.'Load\ Packages\ Menu'
		endif
	endif
endfunction

" }}}

" configuration menu.
if g:Tex_Menus
	exe 'amenu 80.900 '.s:mainmenuname.'Configure\ Menu.Add\ Math\ Menu         :call Tex_MenuConfigure("math", 1)<cr>'
	exe 'amenu 80.900 '.s:mainmenuname.'Configure\ Menu.Remove\ Math\ Menu      :call Tex_MenuConfigure("math", 0)<cr>'
	exe 'amenu 80.900 '.s:mainmenuname.'Configure\ Menu.Expand\ Elements        :call Tex_MenuConfigure("elements", "expand")<cr>'
	exe 'amenu 80.900 '.s:mainmenuname.'Configure\ Menu.Compress\ Elements      :call Tex_MenuConfigure("elements", "nest")<cr>'
	exe 'amenu 80.900 '.s:mainmenuname.'Configure\ Menu.Load\ Packages\ Menu    :call Tex_MenuConfigure("packages", 1)<cr>'
endif

" vim6:fdm=marker
