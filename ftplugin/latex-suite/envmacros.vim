"=============================================================================
" 	     File: envmacros.vim
"      Author: Mikolaj Machowski
"     Created: Tue Apr 23 08:00 PM 2002 PST
" Last Change: pi± lis 15 11:00  2002 C
" 
"  Description: mappings/menus for environments. 
"=============================================================================

if !g:Tex_EnvironmentMaps && !g:Tex_EnvironmentMenus
	finish
endif

exe 'so '.expand('<sfile>:p:h').'/wizardfuncs.vim'

nmap <silent> <script> <plug> i
imap <silent> <script> <C-o><plug> <Nop>

" define environments with special behavior in line wise selection. {{{
if !exists('s:vis_center_left')
	let s:vis_center_left = '\centerline{'
	let s:vis_center_right = '}'

	let s:vis_verbatim_left = '\verb\|'
	let s:vis_verbatim_right = '\|'

	let s:vis_flushright_left =  '{\raggedright '
	let s:vis_flushright_right = '}'

	let s:vis_fushleft_left = '{\raggedleft '
	let s:vis_fushleft_right = '}'

	let s:vis_lrbox_left = '\sbox{'
	let s:vis_lrbox_right = '}'
endif
" }}}
" Tex_EnvMacros: sets up maps and menus for environments {{{
" Description: 
function! <SID>Tex_EnvMacros(lhs, submenu, name)

	let extra = ''
	if a:submenu =~ 'Lists'
		let extra = '\item '
	endif

	let vright = ''
	let vleft = ''
	if exists('s:vis_'.a:name.'_right')
		let vright = s:vis_{a:name}_right
		let vleft = s:vis_{a:name}_left
	endif
	let vrhs = "\<C-\\>\<C-N>:call VEnclose('".vleft."', '".vright."', '\\begin{".a:name."}', '\\end{".a:name."}')\<CR>"
	let location = g:Tex_EnvMenuLocation.a:submenu.a:name.'<tab>'

	if a:lhs != '' 

		let vlhs = g:Tex_Leader2.substitute(tolower(a:lhs), '^.', '', '')
		let location = location.a:lhs.'\ ('.vlhs.')'

		if g:Tex_EnvironmentMaps && !exists('s:doneOnce')
			call IMAP (a:lhs, '\begin{'.a:name."}\<CR>".extra."«»\<CR>\\end{".a:name."}«»", 'tex')
			exec 'vnoremap <silent> '.vlhs.' '.vrhs
		endif

	endif

	if g:Tex_Menus && g:Tex_EnvironmentMenus && has("gui_running")
		exe 'amenu '.location.' <plug><C-r>=Tex_DoEnvironment("'.a:name.'")<CR>'
		exe 'vmenu '.location.' '.vrhs
	endif

endfunction 

" }}}
" Tex_SpecialMacros: macros with special right hand sides {{{
" Description: 
function! <SID>Tex_SpecialMacros(lhs, submenu, name, irhs, ...)

	let wiz = 1
	if a:0 > 0 && a:1 == 0
		let wiz = 0
	endif

	let location = g:Tex_EnvMenuLocation.a:submenu.a:name

	let vright = ''
	let vleft = ''
	if exists('s:vis_'.a:name.'_right')
		let vright = s:vis_{a:name}_right
		let vleft = s:vis_{a:name}_left
	endif
	let vrhs = "\<C-\\>\<C-N>:call VEnclose('".vleft."', '".vright."', '\\begin{".a:name."}', '\\end{".a:name."}')\<CR>"

	if a:lhs != ''

		let vlhs = g:Tex_Leader2.substitute(tolower(a:lhs), '^.', '', '')
		let location = location.'<tab>'.a:lhs.'\ ('.vlhs.')'

		if g:Tex_EnvironmentMaps && !exists('s:doneOnce')
			call IMAP(a:lhs, a:irhs, 'tex')
			exec 'vnoremap '.vlhs.' '.vrhs
		endif

	endif

	if g:Tex_Menus && g:Tex_EnvironmentMenus
		if wiz
			exe 'amenu '.location.' <plug><C-r>=Tex_MenuWizard("'.a:submenu.'", "'.a:name.'")<CR>'
		else
			exe 'amenu '.location." <plug><C-r>=IMAP_PutTextWithMovement('".a:irhs."')<CR>"
		endif
		exe 'vmenu '.location.' '.vrhs
	endif

endfunction " }}}
" Tex_SectionMacros: creates section maps and menus {{{
" Description: 
function! <SID>Tex_SectionMacros(lhs, name)

	let vlhs = g:Tex_Leader2.substitute(tolower(a:lhs), '^.', '', '')
	let vrhs = "\<C-\\>\<C-N>:call VEnclose('\\".a:name."{', '}', '', '')<CR>"

	if g:Tex_SectionMaps && !exists('s:doneOnce')
		exe 'vnoremap '.vlhs.' '.vrhs
		call IMAP (a:lhs, "\\".a:name.'{«»}«»', 'tex')
	endif

	if g:Tex_Menus && g:Tex_SectionMenus
		let location = g:Tex_EnvMenuLocation.'Sections.'.a:name.'<tab>'.a:lhs.'\ ('.vlhs.')'
		let advlocation = g:Tex_EnvMenuLocation.'Sections.Advanced.'.a:name

		let irhs = "\<C-r>=IMAP_PutTextWithMovement('\\".a:name."{«»}«»')\<CR>"

		let advirhs = "\<C-r>=Tex_InsSecAdv('".a:name."')\<CR>"
		let advvrhs = "\<C-\\>\<C-N>:call Tex_VisSecAdv('".a:name."')\<CR>"

		exe 'amenu '.advlocation.' <plug>'.advirhs
		exe 'vnoremenu '.advlocation." ".advvrhs

		exe 'amenu '.location.' <plug>'.irhs
		exe 'vnoremenu '.location." ".vrhs
	endif
endfunction " }}}

" NewEnvironments {{{
call s:Tex_SpecialMacros('', '', 'newenvironment',     '\newenvironment{«»}[«»][«»]{«»}{«»}«»', 0)
call s:Tex_SpecialMacros('', '', 'newenvironment*',    '\newenvironment*{«»}[«»][«»]{«»}{«»}«»', 0)
call s:Tex_SpecialMacros('', '', 'renewenvironment',   '\renewenvironment{«»}[«»][«»]{«»}{«»}«»', 0)
call s:Tex_SpecialMacros('', '', 'renewenvironment*',  '\renewenvironment*{«»}[«»][«»]{«»}{«»}«»', 0)
call s:Tex_SpecialMacros('', '', '-sepenv0-', ' :', 0)
" }}}
" Environments specific commands {{{
call s:Tex_SpecialMacros('', 'Env&Commands.&Lists.', '&item',     '\item', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Lists.', 'i&tem[]',    '\item[«»]«»', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Lists.', '&bibitem{}', '\bibitem{«»}«»', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', '\\&=', '\=', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', '\\&>', '\>', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', '&\\\\', '\\', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', '\\&+', '\+', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', '\\&-', '\-', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', "\\\'", "\\\'", 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', '\\&`', '\`', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', '\\&kill', '\kill', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', '&makron\ \\CHAR=', '\«»=«»', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', "&aigu\ \\CHAR\'", "\\«»\'«»", 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', '&grave\ \\CHAR`', '\«»`«»', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', 'p&ushtabs', '\pushtabs', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', 'p&optabs', '\poptabs', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.&Tabular.', '&hline', '\hline', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.&Tabular.', '&cline', '\cline', 0) 
call s:Tex_SpecialMacros('', 'EnvCommands.&Tabular.', '&\&', '&', 0) 
call s:Tex_SpecialMacros('', 'EnvCommands.&Tabular.', '&\\\\', '\\', 0) 
call s:Tex_SpecialMacros('', 'EnvCommands.&Tabular.', '&multicolumn{}{}{}', '\multicolumn{«»}{«»}{«»}«»', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.Le&tter.', '&makelabels', '\makelabels', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.Le&tter.', '&address', '\address', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.Le&tter.', '&signature', '\signature', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.Le&tter.', '&date', '\date', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.Le&tter.', '-sepenva4-', ' :', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.Le&tter.', '&opening{}', '\opening{«»}«»', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.Le&tter.', '&closing{}', '\closing{«»}«»', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.Le&tter.', '&ps{}', '\ps{«»}«»', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.Le&tter.', 'cc&{}', '\cc{«»}«»', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.&Slides.', '&onlyslides{}', '\onlyslides{«»}«»', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.&Slides.', '&onlynotes{}', '\onlynotes{«»}«»', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.&Slides.', '-sepenva5-', ' :', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.&Slides.', '&invisible', '\invisible', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.&Slides.', '&visible', '\visible', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.&Slides.', '&settime', '\settime', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.&Slides.', '&addtime', '\addtime', 0)
call s:Tex_SpecialMacros('', '', '-sepenv0-', ' :', 0)
" }}}
" Lists {{{
call s:Tex_SpecialMacros('ELI', '&Lists.',  'list', "\\begin{list}{«label»}{«commands»}\<cr>\\item «»\<cr>\\end{list}«»")
call s:Tex_EnvMacros('EEN', '&Lists.', 'enumerate')
call s:Tex_EnvMacros('EIT', '&Lists.', 'itemize')
call s:Tex_EnvMacros('ETI', '&Lists.', 'theindex')
call s:Tex_EnvMacros('ETL', '&Lists.', 'trivlist')
" }}}
" Tables {{{
call s:Tex_SpecialMacros('ETE', '&Tables.', 'table', "\\begin{table}\<cr>\\centering\<cr>\\caption{tab:ä}\<cr>\\begin{tabular}{«dimensions»}\<cr>«»\<cr>\\end{tabular}\<cr>\\label{tab:«label»}\<cr>\\end{table}«»")
call s:Tex_EnvMacros('ETG', '&Tables.', 'tabbing')
call s:Tex_EnvMacros('',    '&Tables.', 'table*')
call s:Tex_EnvMacros('',    '&Tables.', 'table2')
call s:Tex_EnvMacros('ETR', '&Tables.', 'tabular')
call s:Tex_EnvMacros('',    '&Tables.', 'tabular*')
" }}}
" Math {{{
call s:Tex_EnvMacros('EAR', '&Math.', 'array')
call s:Tex_EnvMacros('EDM', '&Math.', 'displaymath')
call s:Tex_EnvMacros('EEA', '&Math.', 'eqnarray')
call s:Tex_EnvMacros('',    '&Math.', 'eqnarray*')
call s:Tex_EnvMacros('EEQ', '&Math.', 'equation')
call s:Tex_EnvMacros('EMA', '&Math.', 'math')
" }}}
" Structure {{{
call s:Tex_SpecialMacros('EAR', 'Math.', 'array', "\\leftä\<cr>\\begin{array}{«dimension»}\<cr>«elements»\<cr>\\end{array}\<cr>\\right«»")
call s:Tex_EnvMacros('EAB', '&Structure.', 'abstract')
call s:Tex_EnvMacros('EAP', '&Structure.', 'appendix')
call s:Tex_EnvMacros('ECE', '&Structure.', 'center')
call s:Tex_EnvMacros('EDO', '&Structure.', 'document')
call s:Tex_EnvMacros('EFC', '&Structure.', 'filecontents')
call s:Tex_EnvMacros('',    '&Structure.', 'filecontents*')
call s:Tex_EnvMacros('EFL', '&Structure.', 'flushleft')
call s:Tex_EnvMacros('EFR', '&Structure.', 'flushright')
call s:Tex_EnvMacros('EQN', '&Structure.', 'quotation')
call s:Tex_EnvMacros('EQE', '&Structure.', 'quote')
call s:Tex_EnvMacros('ESB', '&Structure.', 'sloppybar')
call s:Tex_EnvMacros('ETI', '&Structure.', 'theindex')
call s:Tex_EnvMacros('ETP', '&Structure.', 'titlepage')
call s:Tex_EnvMacros('EVM', '&Structure.', 'verbatim')
call s:Tex_EnvMacros('',    '&Structure.', 'verbatim*')
call s:Tex_EnvMacros('EVE', '&Structure.', 'verse')
call s:Tex_EnvMacros('ETB', '&Structure.', 'thebibliography')
call s:Tex_SpecialMacros('', '&Structure.', '-sepstruct0-', ':', 0)
call s:Tex_EnvMacros('ENO', '&Structure.', 'note')
call s:Tex_EnvMacros('EOV', '&Structure.', 'overlay')
call s:Tex_EnvMacros('ESL', '&Structure.', 'slide')
" }}}
" Sections {{{
call s:Tex_SectionMacros('SPA', 'part')
call s:Tex_SectionMacros('SCH', 'chapter')
call s:Tex_SectionMacros('SSE', 'section')
call s:Tex_SectionMacros('SSS', 'subsection')
call s:Tex_SectionMacros('SS2', 'subsubsection')
call s:Tex_SectionMacros('SPR', 'paragraph')
call s:Tex_SectionMacros('SSP', 'subparagraph')
" }}}
" Miscellaneous {{{
call s:Tex_SpecialMacros('', '', '-sepenv1-', ' :', 0)
call s:Tex_SpecialMacros('EFI', '', 'figure', "\\begin{figure}[«htpb»]\<cr>\\centerline{\\psfig{figure=«eps file»}}\<cr>\\caption{«caption text»}\<cr>\\label{fig:«label»}\<cr>\\end{figure}«»")
call s:Tex_EnvMacros('', '', 'figure*')
call s:Tex_EnvMacros('ELR', '', 'lrbox')
call s:Tex_SpecialMacros('EMP', '', 'minipage', "\\begin{minipage}[«tb»]{«width»}\<cr>«»\<cr>\\end{minipage}«»")
call s:Tex_SpecialMacros('EPI', '', 'picture', "\\begin{picture}(«width», «height»)(«xoff»,«yoff»)\<cr>\\put(«xoff»,«yoff»){\\framebox(«»,«»){«»}}\<cr>\\end{picture}«»")
" }}}

if g:Tex_CatchVisMapErrors
	exe 'vnoremap '.g:Tex_Leader2."   :\<C-u>call ExecMap('".g:Tex_Leader2."', 'v')\<CR>"
endif

" ==============================================================================
" Specialized functions for various environments
" ============================================================================== 
" Tex_itemize: {{{
function! Tex_itemize(indent, env)
	exe 'normal i'.a:indent.'\begin{'.a:env."}\<cr>\\item \<cr>\\end{".a:env."}«»\<Up>"
endfunction
" }}} 
" Tex_description: {{{
function! Tex_description(indent, env)
	let itlabel = input('(Optional) Item label? ')
	if itlabel != ''
		let itlabel = '['.itlabel.']'
	endif
	exe 'normal i'.a:indent."\\begin{description}\<cr>\\item".itlabel." \<cr>\\end{description}«»\<Up>"
endfunction
" }}} 
" Tex_figure: {{{
function! Tex_figure(indent, env)
    let flto    = input('Float to (htbp)? ')
    let caption = input('Caption? ')
    let center  = input('Center ([y]/n)? ')
    let label   = input('Label (for use with \ref)? ')
    " additional to AUC Tex since my pics are usually external files
    let pic = input('Name of Pic-File? ')
    if flto != ''
        let flto = '['.flto."]\<cr>"
    else
        let flto = "\<cr>"
    endif
    if pic != ''
        let pic = '\input{'.pic."}\<cr>"
    else
        let pic = "ä\<cr>"
    endif
    if caption != ''
        let caption = '\caption{'.caption."}\<cr>"
    endif
    if label != ''
        let label = '\label{fig:'.label."}\<cr>"
    endif
    if (center == 'y' || center == '')
      let centr = "\\begin{center}\<cr>"
      let centr = centr . pic 
      let centr = centr . caption
      let centr = centr . label
      let centr = centr . "\\end{center}\<cr>"
    else
      let centr = pic
      let centr = centr . caption
      let centr = centr . label
    endif
    let figure = '\begin{'.a:env.'}'.flto
    let figure = figure . centr
    let figure = figure . '\end{'.a:env.'}'
	exe 'normal i'.a:indent.figure."\<Esc>$"
endfunction
" }}} 
" Tex_table: {{{
function! Tex_table(indent, env)
    let flto    = input('Float to (htbp)? ')
    let caption = input('Caption? ')
    let center  = input('Center (y/n)? ')
    let label   = input('Label? ')
    if flto != ''
        let flto ='['.flto."]\<cr>"
    else
        let flto = ''
    endif
    let ret='\begin{table}'.flto
    if center == 'y'
        let ret=ret."\\begin{center}\<cr>"
    endif
    let foo = '\begin{tabular}'
    let pos = input('(Optional) Position (t b)? ')
    if pos != ''
        let foo = foo.'['.pos.']'
	else
		let foo = foo."\<cr>"
    endif
    let format = input("Format  ( l r c p{width} | @{text} )? ")
	if format == ''
		let format = '«»'
	endif
    let ret = ret.foo.'{'.format."}\<cr>ä\<cr>\\end{tabular}«»\<cr>"
    if center == 'y'
        let ret=ret."\\end{center}\<cr>"
    endif
    if caption != ''
        let ret=ret.'\caption{'.caption."}\<cr>"
    endif
    if label != ''
        let ret=ret.'\label{tab:'.label."}\<cr>"
    endif
    let ret=ret.'\end{table}«»'
	exe 'normal i'.ret."\<Esc>?ä\<cr>:nohl\<cr>C"
endfunction
" }}} 
" Tex_tabular: {{{
function! Tex_tabular(indent, env)
    let pos    = input('(Optional) Position (t b)? ')
    let format = input("Format  ( l r c p{width} | @{text} )? ")
    if pos != ''
      let pos = '['.pos.']'
    endif
    if format != ''
      let format = '{'.format.'}'
    endif
    exe 'normal i'.a:indent.'\begin{'.a:env.'}'.pos.format."\<cr> \<cr>\\end{".a:env."}«»\<Up>"
endfunction
" }}} 
" Tex_eqnarray: {{{
function! Tex_eqnarray(indent, env)
    let label = input('Label?  ')
    if label != ''
        let arrlabel = '\label{'.label."}\<cr> "
      else
        let arrlabel = ' '
    endif
    exe 'normal i'.a:indent.'\begin{'.a:env."}\<cr>".arrlabel."\<cr>\\end{".a:env."}«»\<Up>"
endfunction
" }}} 
" Tex_list: {{{
function! Tex_list(indent, env)
	let label = input('Label (for \item)? ')
	if label != ''
		let label = '{'.label.'}'
		let addcmd = input('Additional commands? ')
		if addcmd != ''
			let label = label . '{'.addcmd.'}'
		endif
	else
		let label = ''
	endif
	exe 'normal i'.a:indent.'\begin{list}'.label."\<cr>\\item \<cr>\\end{list}«»\<Up>"
endfunction
" }}} 
" Tex_document: {{{
function! Tex_document(indent, env)
    let dstyle = input('Document style? ')
    let opts = input('(Optional) Options? ')
    let foo = '\documentclass'
    if opts == ''
        let foo = foo.'{'.dstyle.'}'
    else
        let foo = foo.'['.opts.']'.'{'.dstyle.'}'
    endif
    exe 'normal i'.a:indent.foo."\<cr>\<cr>\\begin{document}\<cr>\<cr>\\end{document}\<Up>"
endfunction
" }}} 
" Tex_minipage: {{{
function! Tex_minipage(indent, env)
    let foo = '\begin{minipage}'
    let pos = input('(Optional) Position (t b)? ')
    let width = input('Width? ')
    if pos == ''
        let foo = foo.'{'.width.'}'
    else
        let  foo = foo.'['.pos.']{'.width.'}'
    endif
    exe 'normal i'.a:indent.foo."\<cr> \<cr>\\end{minipage}«»\<Up>"
endfunction
" }}} 
" Tex_thebibliography: {{{
function! Tex_thebibliography(indent, env)
    " AUC Tex: "Label for BibItem: 99"
    let indent = input('Indent for BibItem? ')
    let foo = '{'.indent.'}'
    let biblabel = input('(Optional) Bibitem label? ')
    let key = input('Add key? ')
    let bar = '\bibitem'
    if biblabel != ''
        let bar = bar.'['.biblabel.']'
    endif
    let bar = bar.'{'.key.'}'
    exe 'normal i'.a:indent.'\begin{thebibliography}'.foo."\<cr>".bar." \<cr>\\end{thebibliography}«»\<Up>"
endfunction
" }}} 

" Merged contributions from Carl Mueller
" asdf is a fake argument to recognize if call is coming from keyboard or from
" menu 
inoremap <F5> <C-O>:call Tex_FFive_intelligent()<cr>
noremap  <F5> :call Tex_FFive_intelligent()<cr>
function! Tex_FFive_intelligent() " {{{
	let start_line = line('.')
	let pos = line('.').' | normal! '.virtcol('.').'|'
	if search('\\documentclass', 'bW') && search('\\begin{document}')
		let begin_line = search('\\begin{document}')
		if start_line < begin_line
			exe pos
			call Tex_package_from_line()
		else
			exe pos
			call Tex_DoEnvironment('asdf')
		endif
	elseif search('\\documentclass')
		exe pos
		call Tex_package_from_line()
	else
		exe pos
		call Tex_DoEnvironment('asdf')
	endif
endfunction " }}}
function! Tex_package_from_line() " {{{
	" Function Tex_PutPackage is defined in packages.vim
	let l = getline(".")
	let pack = matchstr(l, '^\s*\zs.*')
	if pack == ''
		let pack = input('Package? ')
		if pack != ''
			call Tex_PutPackage(pack)
		endif
		return 0
	else
		normal 0D
		call Tex_PutPackage(pack)
	endif
endfunction " }}}


function! Tex_DoEnvironment(env) " {{{
	let l = getline('.')
	if a:env == 'asdf'
		let env = matchstr(l, '^\s*\zs.*')
		if env == ''
			let env = input('Environment? ')
			if env != ''
				call Tex_PutEnvironment(l, env)
			endif
		else
			let ind = matchstr(l, '^\s*\ze')
			normal 0D
			call Tex_PutEnvironment(ind, env)
		endif
	else
		call Tex_PutEnvironment(l, a:env)
	endif
	startinsert
endfunction " }}}
function! Tex_PutEnvironment(indent, env) " {{{
	if a:env =~ "theorem\\|lemma\\|equation\\|eqnarray\\|align\\|multline"
		call Tex_eqnarray(a:indent, a:env)
	elseif a:env =~ "enumerate\\|itemize\\|theindex\\|trivlist"
		call Tex_itemize(a:indent, a:env)
    elseif a:env =~ "table\\|table*"
        call Tex_table(a:indent, a:env)
    elseif a:env =~ "tabular\\|tabular*\\|array\\|array*"
        call Tex_tabular(a:indent, a:env)
	elseif exists('*Tex_'.a:env)
		exe 'call Tex_'.a:env.'(a:indent, a:env)'
	else
        exe 'normal i'.a:indent.'\begin{'.a:env."}\<cr> \<cr>\\end{".a:env."}«»\<Up>"
	endif
endfunction " }}}

let b:DoubleDollars = 0

inoremap <buffer> <S-F5> <C-O>:call Tex_change_environment()<CR>
noremap  <buffer> <S-F5> :call Tex_change_environment()<CR>

function! Tex_AmsLatex() " {{{
	if g:Tex_package_supported =~ 'amsmath'
		let amslatex = 1
	endif
    return amslatex
endfunction " }}}

"let b:searchmax = 100
let s:math_environment = 'eqnarray,eqnarray*,align,align*,equation,equation*,[,$$'
let s:item_environment = 'list,trivlist,enumerate,itemize,theindex'
function Tex_change_environment() " {{{
    let env_line = searchpair("\\[\\|begin{", '', "\\]\\|end{", "bn")
	if env_line != 0
		if getline(env_line) !~ 'begin{'
			let env_name = '['
		else
			let env_name = matchstr(getline(env_line), 'begin{\zs.\{-}\ze}')
		endif
	endif
	if !exists('env_name')
		echomsg "You are not inside environment"
		return 0
	endif
	if s:math_environment =~ env_name
		exe "let change_env = input('You are within a \"".env_name."\" environment.\n".
				\ "Do you want to change it to?\n".
				\ "(1) eqnarray  (2) eqnarray*\n".
				\ "(3) align     (4) align*\n".
				\ "(5) equation* (6) other\n".
				\ "<cr>  leave unchanged\n".
				\ "Enter number: ')"
		if change_env == 1
			call <SID>Change('eqnarray', 1, '', 1)
		elseif change_env == 2
			call <SID>Change('eqnarray*', 0, '\\nonumber', 0)
		elseif change_env == 3
			call <SID>Change('align', 1, '', 1)
		elseif change_env == 4
			call <SID>Change('align*', 0, '\\nonumber', 0)
		elseif change_env == 5
			call <SID>Change('equation*', 0, '&\|\\lefteqn{\|\\nonumber\|\\\\', 0)
		elseif change_env == 6
			let env = input('Environment? ')
			if env != ''
				call <SID>Change(env, 0, '', '')
			endif
			return 0
		elseif change_env == ''
			return 0
		else
			echomsg 'Wrong argument'
			return 0
		endif
	else
		exe "let change_env = input('You are within a \"".env_name."\" environment.\n".
					\ "You want to change it for (<cr> to abandon): ')"
		if change_env == ''
			return 0
		else
			call <SID>Change(change_env, 0, '', '')
		endif
	endif
endfunction " }}}
function! s:Change(env, label, delete, putInNonumber) " {{{
	let start_line = line('.')
	let start_col = virtcol('.')
	if a:env == '['
		if b:DoubleDollars == 0
			let first = '\\['
			let second = '\\]'
		else
			let first = '$$'
			let second = '$$'
		endif
	else
		let first = '\\begin{' . a:env . '}'
		let second = '\\end{' . a:env . '}'
	endif
	if b:DoubleDollars == 0
		let bottom = searchpair('\\\[\|\\begin{','','\\\]\|\\end{','')
		s/\\\]\|\\end{.\{-}}/\=second/
		let top = searchpair('\\\[\|\\begin{','','\\\]\|\\end{','b')
		s/\\\[\|\\begin{.\{-}}/\=first/
	else
		let bottom = search('\$\$\|\\end{')
		s/\$\$\|\\end{.\{-}}/\=second/
		let top = search('\$\$\|\\begin{','b')
		s/\$\$\|\\begin{.\{-}}/\=first/
	end
	if a:delete != ''
		exe 'silent '. top . "," . bottom . 's/' . a:delete . '//e'
	endif
	if a:putInNonumber == 1
		exe top
		call search('\\end\|\\\\')
		if line('.') != bottom
			exe '.+1,' . bottom . 's/\\\\/\\nonumber\\\\/e'
			exe (bottom-1) . 's/\s*$/  \\nonumber/'
		endif
	endif
	if a:label == 1
		exe top
		if search("\\label", "W") > bottom
			exe top
			let local_label = input('Label? ')
			if local_label != ''
				put = '\label{'.local_label.'}'
			endif
			normal $
		endif
	else
		exe 'silent '.top . ',' . bottom . ' g/\\label/delete'
	endif
	if exists('local_label') && local_label != ''
		exe start_line + 1.' | normal! '.start_col.'|'
	else
		exe start_line.' | normal! '.start_col.'|'
	endif
endfunction " }}}

" Due to Ralf Arens <ralf.arens@gmx.net>
function! s:ArgumentsForArray(arg) " {{{
	put! = '{' . a:arg . '}'
	normal kgJj
endfunction 
" }}}
function! s:PutInNonumber() " {{{
	call search('\\end\|\\\\')
	if getline(line('.'))[col('.')] != "e"
		.+1,'>s/\\\\/\\nonumber\\\\/e
		normal `>k
		s/\s*$/  \\nonumber/
	endif
endfunction 
" }}}

" this statement has to be at the end.
let s:doneOnce = 1

" vim:fdm=marker:nowrap:noet

