"=============================================================================
"        File: texmenuconf.vim
"      Author: Srinath Avadhanula <srinath@fastmail.fm>
" Description: 
" 
"=============================================================================

" Paths, crucial for functions
let s:path = expand("<sfile>:p:h")
let s:up_path = expand("<sfile>:p:h:h")
let s:mainmenuname = g:Tex_MenuPrefix.'Suite.'

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
	exec 'anoremenu 80.25 '. s:mainmenuname.'-sepsuite0-  :'

	" menus for compiling / viewing etc.
	exec 'anoremenu 80.30 '.s:mainmenuname.'&Compile<tab>\\ll'.
		\'   :silent! call RunLaTeX()<CR>'
	exec 'anoremenu 80.35 '.s:mainmenuname.'Compile&Part<tab>\\lc'.
		\'   :silent! call Tex_PartCompilation("fline","lline", "v")<CR>'
	exec 'anoremenu 80.40 '.s:mainmenuname.'&View<tab>\\lv'.
		\'   :silent! call ViewLaTeX("all")<CR>'
	exec 'anoremenu 80.45 '.s:mainmenuname.'Vi&ewPart<tab>\\lp'.
		\'   :silent! call ViewLaTeX("part")<CR>'
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
	exec 'inoremenu 80.100 '.s:mainmenuname.'C&omplete\ Ref/Cite'.
		\'   <Esc>:call Tex_viewer("default","text")<CR>'
	exec 'anoremenu 80.110 '.s:mainmenuname.'-sepsuite1- :'
	" refreshing folds
	if g:Tex_Folding
		exec 'anoremenu 80.120 '.s:mainmenuname.'&Refresh\ Folds<tab>\\rf'.
			\'   :call MakeTexFolds(1)<CR>'
		exec 'anoremenu 80.130 '.s:mainmenuname.'-sepsuite2- :'
	endif
	" editing private texrc
	exec 'anoremenu 80.140 '.s:mainmenuname.'Edit\ &texrc<tab>:Ttexrc'.
			\' :Ttexrc<CR>'

endif

" }}}

" ==============================================================================
" Edittexrc: split window and show texrc
" ============================================================================== 
command! -nargs=0 Ttexrc :call Tex_texrc()
function! Tex_texrc()
	if filereadable(s:up_path.'/tex/texrc')
		exec 'split '.s:up_path.'/tex/texrc'
		lcd
	else
		echomsg "Please, create your own texrc by copying system texrc"
					\ ." into ftplugin/tex directory"
	endif
endfunction

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

" vim:fdm=marker:ff=unix:noet:ts=4:sw=4
