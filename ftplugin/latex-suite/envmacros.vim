"=============================================================================
" 	     File: envmacros.vim
"      Author: Mikolaj Machowski
"     Created: Tue Apr 23 08:00 PM 2002 PST
"  CVS Header: 
"  $Header$
"  Description: mappings/menus for environments. 
"=============================================================================

if !g:Tex_EnvironmentMaps && !g:Tex_EnvironmentMenus
	finish
endif

exe 'so '.expand('<sfile>:p:h').'/wizardfuncs.vim'

nmap <silent> <script> <plug> i
imap <silent> <script> <C-o><plug> <Nop>

" Define environments for IMAP evaluation " {{{
let s:figure =     "\\begin{figure}[<+htpb+>]\<cr>\\begin{center}\<cr>\\psfig{figure=<+eps file+>}\<cr>\\end{center}\<cr>\\caption{<+caption text+>}\<cr>\\label{fig:<+label+>}\<cr>\\end{figure}<++>"
let s:minipage =   "\\begin{minipage}[<+tb+>]{<+width+>}\<cr><++>\<cr>\\end{minipage}<++>"
let s:picture =    "\\begin{picture}(<+width+>, <+height+>)(<+xoff+>,<+yoff+>)\<cr>\\put(<+xoff+>,<+yoff+>){\\framebox(<++>,<++>){<++>}}\<cr>\\end{picture}<++>"
let s:list =       "\\begin{list}{<+label+>}{<+commands+>}\<cr>\\item <++>\<cr>\\end{list}<++>"
let s:enumerate =  "\\begin{enumerate}{<+label+>}{<+commands+>}\<cr>\\item <++>\<cr>\\end{enumerate}<++>"
let s:itemize =    "\\begin{itemize}{<+label+>}{<+commands+>}\<cr>\\item <++>\<cr>\\end{itemize}<++>"
let s:theindex =   "\\begin{theindex}{<+label+>}{<+commands+>}\<cr>\\item <++>\<cr>\\end{theindex}<++>"
let s:trivlist =   "\\begin{trivlist}{<+label+>}{<+commands+>}\<cr>\\item <++>\<cr>\\end{trivlist}<++>"
let s:table =      "\\begin{table}\<cr>\\centering\<cr>\\begin{tabular}{<+dimensions+>}\<cr><++>\<cr>\\end{tabular}\<cr>\\caption{<+Caption text+>}\<cr>\\label{tab:<+label+>}\<cr>\\end{table}<++>"
let s:array =      "\\left<++>\<cr>\\begin{array}{<+dimension+>}\<cr><+elements+>\<cr>\\end{array}\<cr>\\right<++>"
let s:description ="\\begin{description}\<cr>\\item[<+label+>]<++>\<cr>\\end{description}<++>"
let s:document =   "\\documentclass[<+options+>]{<+class+>}\<cr>\<cr>\\begin{document}\<cr><++>\<cr>\\end{document}"

" }}}
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
			call IMAP (a:lhs, '\begin{'.a:name."}\<CR>".extra."<++>\<CR>\\end{".a:name."}<++>", 'tex')
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
			exe 'amenu '.location.' <plug><C-r>=Tex_DoEnvironment("'.a:name.'")<CR>'
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
		call IMAP (a:lhs, "\\".a:name.'{<++>}<++>', 'tex')
	endif

	if g:Tex_Menus && g:Tex_SectionMenus
		let location = g:Tex_EnvMenuLocation.'Sections.'.a:name.'<tab>'.a:lhs.'\ ('.vlhs.')'
		let advlocation = g:Tex_EnvMenuLocation.'Sections.Advanced.'.a:name

		let irhs = "\<C-r>=IMAP_PutTextWithMovement('\\".a:name."{<++>}<++>')\<CR>"

		let advirhs = "\<C-r>=Tex_InsSecAdv('".a:name."')\<CR>"
		let advvrhs = "\<C-\\>\<C-N>:call Tex_VisSecAdv('".a:name."')\<CR>"

		exe 'amenu '.advlocation.' <plug>'.advirhs
		exe 'vnoremenu '.advlocation." ".advvrhs

		exe 'amenu '.location.' <plug>'.irhs
		exe 'vnoremenu '.location." ".vrhs
	endif
endfunction " }}}

" NewEnvironments {{{
call s:Tex_SpecialMacros('', '', 'newenvironment',     '\newenvironment{<++>}[<++>][<++>]{<++>}{<++>}<++>', 0)
call s:Tex_SpecialMacros('', '', 'newenvironment*',    '\newenvironment*{<++>}[<++>][<++>]{<++>}{<++>}<++>', 0)
call s:Tex_SpecialMacros('', '', 'renewenvironment',   '\renewenvironment{<++>}[<++>][<++>]{<++>}{<++>}<++>', 0)
call s:Tex_SpecialMacros('', '', 'renewenvironment*',  '\renewenvironment*{<++>}[<++>][<++>]{<++>}{<++>}<++>', 0)
call s:Tex_SpecialMacros('', '', '-sepenv0-', ' :', 0)
" }}}
" Environments specific commands {{{
call s:Tex_SpecialMacros('', 'Env&Commands.&Lists.', '&item',     '\item', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Lists.', 'i&tem[]',    '\item[<++>]<++>', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Lists.', '&bibitem{}', '\bibitem{<++>}<++>', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', '\\&=', '\=', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', '\\&>', '\>', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', '&\\\\', '\\', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', '\\&+', '\+', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', '\\&-', '\-', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', "\\\'", "\\\'", 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', '\\&`', '\`', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', '\\&kill', '\kill', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', '&makron\ \\CHAR=', '\<++>=<++>', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', "&aigu\ \\CHAR\'", "\\<++>\'<++>", 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', '&grave\ \\CHAR`', '\<++>`<++>', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', 'p&ushtabs', '\pushtabs', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', 'p&optabs', '\poptabs', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.&Tabular.', '&hline', '\hline', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.&Tabular.', '&cline', '\cline', 0) 
call s:Tex_SpecialMacros('', 'EnvCommands.&Tabular.', '&\&', '&', 0) 
call s:Tex_SpecialMacros('', 'EnvCommands.&Tabular.', '&\\\\', '\\', 0) 
call s:Tex_SpecialMacros('', 'EnvCommands.&Tabular.', '&multicolumn{}{}{}', '\multicolumn{<++>}{<++>}{<++>}<++>', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.Le&tter.', '&makelabels', '\makelabels', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.Le&tter.', '&address', '\address', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.Le&tter.', '&signature', '\signature', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.Le&tter.', '&date', '\date', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.Le&tter.', '-sepenva4-', ' :', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.Le&tter.', '&opening{}', '\opening{<++>}<++>', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.Le&tter.', '&closing{}', '\closing{<++>}<++>', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.Le&tter.', '&ps{}', '\ps{<++>}<++>', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.Le&tter.', 'cc&{}', '\cc{<++>}<++>', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.&Slides.', '&onlyslides{}', '\onlyslides{<++>}<++>', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.&Slides.', '&onlynotes{}', '\onlynotes{<++>}<++>', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.&Slides.', '-sepenva5-', ' :', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.&Slides.', '&invisible', '\invisible', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.&Slides.', '&visible', '\visible', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.&Slides.', '&settime', '\settime', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.&Slides.', '&addtime', '\addtime', 0)
call s:Tex_SpecialMacros('', '', '-sepenv0-', ' :', 0)
" }}}
" Lists {{{
call s:Tex_SpecialMacros('ELI', '&Lists.',  'list', s:list)
call s:Tex_EnvMacros('EEN', '&Lists.', 'enumerate')
call s:Tex_EnvMacros('EIT', '&Lists.', 'itemize')
call s:Tex_EnvMacros('ETI', '&Lists.', 'theindex')
call s:Tex_EnvMacros('ETL', '&Lists.', 'trivlist')
" }}}
" Tables {{{
call s:Tex_SpecialMacros('ETE', '&Tables.', 'table', s:table)
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
call s:Tex_SpecialMacros('EAR', 'Math.', 'array', s:array)
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
call s:Tex_SpecialMacros('EFI', '', 'figure', s:figure)
call s:Tex_EnvMacros('', '', 'figure*')
call s:Tex_EnvMacros('ELR', '', 'lrbox')
call s:Tex_SpecialMacros('EMP', '', 'minipage', s:minipage)
call s:Tex_SpecialMacros('EPI', '', 'picture', s:picture)
" }}}

if g:Tex_CatchVisMapErrors
	exe 'vnoremap '.g:Tex_Leader2."   :\<C-u>call ExecMap('".g:Tex_Leader2."', 'v')\<CR>"
endif

" ==============================================================================
" Specialized functions for various environments
"
" All these functions are to be used as:
"
"   inoremap <lhs> <C-r>=Tex_itemize('enumerate')<CR>
"   nnoremap <lhs> i<C-r>=Tex_itemize('enumerate')<CR>
"
" and so on...
" ============================================================================== 
" Tex_itemize: {{{
function! Tex_itemize(env)
	return IMAP_PutTextWithMovement('\begin{'.a:env."}\<cr>\\item <++>\<cr>\\end{".a:env."}<++>")
endfunction
" }}} 
" Tex_description: {{{
function! Tex_description(env)
	if g:Tex_UseMenuWizard == 1
		let itlabel = input('(Optional) Item label? ')
		if itlabel != ''
			let itlabel = '['.itlabel.']'
		endif
		return IMAP_PutTextWithMovement("\\begin{description}\<cr>\\item".itlabel." <++>\<cr>\\end{description}<++>")
	else
		return IMAP_PutTextWithMovement(s:description)
	endif
endfunction
" }}} 
" Tex_figure: {{{
function! Tex_figure(env)
	if g:Tex_UseMenuWizard == 1
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
			let pic = "<++>\<cr>"
		endif
		if caption != ''
			let caption = '\caption{'.caption."}\<cr>"
		endif
		if label != ''
			let label = '\label{fig:'.label."}\<cr>"
		endif
		if center == 'y'
		  let centr = '\begin{center}' . "\<cr>"
		  let centr = centr . pic 
		  let centr = centr . caption
		  let centr = centr . label
		  let centr = centr . '\end{center}' . "\<cr>"
		else
		  let centr = pic
		  let centr = centr . caption
		  let centr = centr . label
		endif
		let figure = '\begin{'.a:env.'}'.flto
		let figure = figure . centr
		let figure = figure . '\end{'.a:env.'}'
		return IMAP_PutTextWithMovement(figure)
	else
		return IMAP_PutTextWithMovement(s:figure)
	endif
endfunction
" }}} 
" Tex_table: {{{
function! Tex_table(env)
	if g:Tex_UseMenuWizard == 1
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
			let format = '<++>'
		endif
		let ret = ret.foo.'{'.format."}\<cr><++>\<cr>\\end{tabular}<++>\<cr>"
		if center == 'y'
			let ret=ret."\\end{center}\<cr>"
		endif
		if caption != ''
			let ret=ret.'\caption{'.caption."}\<cr>"
		endif
		if label != ''
			let ret=ret.'\label{tab:'.label."}\<cr>"
		endif
		let ret=ret.'\end{table}<++>'
		return IMAP_PutTextWithMovement(ret)
	else
		return IMAP_PutTextWithMovement(s:table)
	endif
endfunction
" }}} 
" Tex_tabular: {{{
function! Tex_tabular(env)
	if Tex_UseMenuWizard == 1
		let pos    = input('(Optional) Position (t b)? ')
		let format = input("Format  ( l r c p{width} | @{text} )? ")
		if pos != ''
		  let pos = '['.pos.']'
		endif
		if format != ''
		  let format = '{'.format.'}'
		endif
		return IMAP_PutTextWithMovement('\begin{'.a:env.'}'.pos.format."\<cr> \<cr>\\end{".a:env.'}<++>')
	else
		return IMAP_PutTextWithMovement('\begin{'.a:env.'}[<+position+>]{<+format+>}'."\<cr><++>\<cr>\\end{".a:env.'}<++>')
	endif
endfunction
" }}} 
" Tex_eqnarray: {{{
function! Tex_eqnarray(env)
	if g:Tex_UseMenuWizard == 1
		if a:env !~ '\*'
			let label = input('Label?  ')
			if label != ''
				let arrlabel = '\label{'.label."}\<cr> "
			  else
				let arrlabel = ''
			endif
		else
			let arrlabel = ''
		endif
		return IMAP_PutTextWithMovement('\begin{'.a:env."}\<cr>".arrlabel."<++>\<cr>\\end{".a:env."}<++>")
	else
		if a:env !~ '\*'
			let arrlabel = '\label{<++>}<++>'
		else
			let arrlabel = '<++>'
		endif
		return IMAP_PutTextWithMovement('\begin{'.a:env."}\<cr>".arrlabel."\<cr>".'\end{'.a:env.'}<++>')
	endif
endfunction
" }}} 
" Tex_list: {{{
function! Tex_list(env)
	if g:Tex_UseMenuWizard == 1
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
		return IMAP_PutTextWithMovement('\begin{list}'.label."\<cr>\\item \<cr>\\end{list}<++>")
	else
		return IMAP_PutTextWithMovement(s:list)
	endif
endfunction
" }}} 
" Tex_document: {{{
function! Tex_document(env)
	if g:Tex_UseMenuWizard == 1
		let dstyle = input('Document style? ')
		let opts = input('(Optional) Options? ')
		let foo = '\documentclass'
		if opts == ''
			let foo = foo.'{'.dstyle.'}'
		else
			let foo = foo.'['.opts.']'.'{'.dstyle.'}'
		endif
		return IMAP_PutTextWithMovement(foo."\<cr>\<cr>\\begin{document}\<cr><++>\<cr>\\end{document}")
	else
		return IMAP_PutTextWithMovement(s:document)
	endif
endfunction
" }}} 
" Tex_minipage: {{{
function! Tex_minipage(env)
	if g:Tex_UseMenuWizard == 1
		let foo = '\begin{minipage}'
		let pos = input('(Optional) Position (t b)? ')
		let width = input('Width? ')
		if pos == ''
			let foo = foo.'{'.width.'}'
		else
			let  foo = foo.'['.pos.']{'.width.'}'
		endif
		return IMAP_PutTextWithMovement(foo."\<cr><++>\<cr>\\end{minipage}<++>")
	else
		return IMAP_PutTextWithMovement(s:minipage)
	endif
endfunction
" }}} 
" Tex_thebibliography: {{{
function! Tex_thebibliography(env)
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
    return IMAP_PutTextWithMovement('\begin{thebibliography}'.foo."\<cr>".bar." \<cr>\\end{thebibliography}<++>\<Up>")
endfunction
" }}} 

" ==============================================================================
" Contributions / suggestions from Carl Mueller (auctex.vim)
" ============================================================================== 
" SetUpEnvironmentsPrompt: sets up a prompt string using g:Tex_PromptedEnvironments {{{
" Description: 
" 
function! SetUpEnvironmentsPrompt()
	let num_common = GetListCount(g:Tex_PromptedEnvironments)

	let i = 1
	let s:common_env_prompt = "\n"

	while i < num_common

		let env1 = Tex_Strntok(g:Tex_PromptedEnvironments, ',', i)
		let env2 = Tex_Strntok(g:Tex_PromptedEnvironments, ',', i + 1)

		let s:common_env_prompt = s:common_env_prompt.'('.i.') '.env1."\t".( strlen(env1) < 4 ? "\t" : '' ).'('.(i+1).') '.env2."\n"

		let i = i + 2
	endwhile
	let s:common_env_prompt = s:common_env_prompt.'Enter number or name of environment: '
endfunction " }}}
" PromptForEnvironment: prompts for an environment {{{
" Description: 
function! PromptForEnvironment(ask)

	if !exists('s:common_env_prompt')
		call SetUpEnvironmentsPrompt()
	endif

	let inp = input(a:ask.s:common_env_prompt)
	if inp =~ '^[0-9]$'
		let env = Tex_Strntok(g:Tex_PromptedEnvironments, ',', inp)
	else
		let env = inp
	endif

	return env
endfunction " }}}
" Tex_DoEnvironment: fast insertion of environments {{{
" Description:
"   The menus call this function with an argument (the name of the environment
"   to insert). The maps call this without any arguments. In this case, it
"   prompts for an environment to enter if the current line is empty. If
"   called without arguments and there is a word on the current line, then use
"   that as the name of a new environment.
function! Tex_DoEnvironment(...)
	if a:0 < 1
		let env = matchstr(getline('.'), '^\s*\zs\w*\*\=\ze\s*$')
		if env == ''
			let env = PromptForEnvironment('Choose which environment to insert: ')
			if env != ''
				return Tex_PutEnvironment(env)
			else
				return ''
			endif
		else
			" delete the word on the line into the blackhole register.
			normal! 0"_D
			return Tex_PutEnvironment(env)
		endif
	else
		return Tex_PutEnvironment(a:1)
	endif
endfunction " }}}
" Tex_PutEnvironment: calls various specialized functions {{{
" Description: 
"   Based on input argument, it calls various specialized functions.
function! Tex_PutEnvironment(env)
	if s:isvisual == "yes"
		return VEnclose('\begin{'.a:env.'}', '\end{'.a:env.'}', '\begin{'.a:env.'}', '\end{'.a:env.'}')
	else
		if a:env =~ "equation*\\|eqnarray*\\|align*\\|theorem\\|lemma\\|equation\\|eqnarray\\|align\\|multline"
			return Tex_eqnarray(a:env)
		elseif a:env =~ "enumerate\\|itemize\\|theindex\\|trivlist"
			return Tex_itemize(a:env)
		elseif a:env =~ "table\\|table*"
			return Tex_table(a:env)
		elseif a:env =~ "tabular\\|tabular*\\|array\\|array*"
			return Tex_tabular(a:env)
		elseif exists('*Tex_'.a:env)
			exe 'return Tex_'.a:env.'(a:env)'
		elseif a:env == '$$'
			return IMAP_PutTextWithMovement('$$<++>$$')
		elseif a:env == '['
			return IMAP_PutTextWithMovement("\\[\<CR><++>\<CR>\\]<++>")
		else
			return IMAP_PutTextWithMovement('\begin{'.a:env."}\<cr><++>\<cr>\\end{".a:env."}<++>")
		endif
	endif
endfunction " }}}
" Mapping the <F5> key to insert/prompt for an environment/package {{{
" and <S-F5> to prompt/replace an environment
"
" g:Tex_PromptedEnvironments is a variable containing a comma seperated list
" of environments. This list defines the prompt which latex-suite sets up when
" the user presses <F5> on an empty line.
"
" Leaving this empty is equivalent to disabling the feature.
if g:Tex_PromptedEnvironments != ''

	let b:DoubleDollars = 0

	" Provide only <plug>s here. main.vim will create the actual maps.
	inoremap <silent> <Plug>Tex_FastEnvironmentInsert  <C-r>=Tex_FastEnvironmentInsert("no")<cr>
	nnoremap <silent> <Plug>Tex_FastEnvironmentInsert  i<C-r>=Tex_FastEnvironmentInsert("no")<cr>
	inoremap <silent> <Plug>Tex_FastEnvironmentChange  <C-O>:call Tex_ChangeEnvironments("no")<CR>
	nnoremap <silent> <Plug>Tex_FastEnvironmentChange  :call Tex_ChangeEnvironments("no")<CR>
	vnoremap <silent> <Plug>Tex_FastEnvironmentInsert  <C-\><C-N>:call Tex_FastEnvironmentInsert("yes")<CR>

	" Tex_FastEnvironmentInsert: maps <F5> to prompt for env and insert it " {{{
	" Description:
	"   This function calculates whether we are in the preamble. If we are
	"   then inserts a \usepackage line by either reading in a word from the
	"   current line or prompting to type in one. If not in the preamble, then
	"   inserts a environment template either by reading in a word from the
	"   current line or prompting the user to choose one.
	"
	function! Tex_FastEnvironmentInsert(isvisual)

		let start_line = line('.')
		let pos = line('.').' | normal! '.virtcol('.').'|'
		let s:isvisual = a:isvisual

		" decide if we are in the preamble of the document. If we are then
		" insert a package, otherwise insert an environment.
		"
		if search('\\documentclass', 'bW') && search('\\begin{document}')

			" If there is a \documentclass line and a \begin{document} line in
			" the file, then a part of the file is the preamble.

			" search for where the document begins.
			let begin_line = search('\\begin{document}')
			" if the document begins after where we are presently, then we are
			" in the preamble.
			if start_line < begin_line
				" return to our original location and insert a package
				" statement.
				exe pos
				return Tex_package_from_line()
			else
				" we are after the preamble. insert an environment.
				exe pos
				return Tex_DoEnvironment()
			endif

		elseif search('\\documentclass')
			" if there is only a \documentclass but no \begin{document}, then
			" the entire file is a preamble. Put a package.

			exe pos
			return Tex_package_from_line()

		else
			" no \documentclass, put an environment.

			exe pos
			return Tex_DoEnvironment()

		endif

	endfunction 

	" }}}
	" Tex_package_from_line: puts a \usepackage line in the current line. " {{{
	" Description:
	"
	function! Tex_package_from_line()
		" Function Tex_PutPackage is defined in packages.vim
		" Ignores <F5> in Visual mode 
		if s:isvisual == "yes"
			return 0
		else	   
			let l = getline(".")
			let pack = matchstr(l, '^\s*\zs.*')
			normal!  0"_D
			return Tex_pack_one(pack)
		endif
	endfunction 
	
	" }}}
	" Tex_ChangeEnvironments: calls Change() to change the environment {{{
	" Description:
	"   Finds out which environment the cursor is positioned in and changes
	"   that to the chosen new environment. This function knows the changes
	"   which need to be made to change one env to another and calls
	"   Change() with the info.
	"
	function! Tex_ChangeEnvironments() 

		let env_line = searchpair('$$\|\\[\|begin{', '', '$$\|\\]\|end{', "bn")

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

		exe 'echomsg "You are within a '.env_name.' environment."'
		let s:change_env = PromptForEnvironment('Do you want to change it to (number or name)? ')

		if s:change_env == 'eqnarray'
			call <SID>Change('eqnarray', 1, '', 1)
		elseif s:change_env == 'eqnarray*'
			call <SID>Change('eqnarray*', 0, '\\nonumber', 0)
		elseif s:change_env == 'align'
			call <SID>Change('align', 1, '', 1)
		elseif s:change_env == 'align*'
			call <SID>Change('align*', 0, '\\nonumber', 0)
		elseif s:change_env == 'equation*'
			call <SID>Change('equation*', 0, '&\|\\lefteqn{\|\\nonumber\|\\\\', 0)
		elseif s:change_env == ''
			return 0
		else
			call <SID>Change(s:change_env, 0, '', '')
			return 0
		endif

	endfunction 
	
	" }}}
	" Change: changes the current env to the new env {{{
	" Description: 
	"   This function needs to know the changes which need to be made while
	"   going from an old environment to a new one. This info, it gets from
	"   Tex_ChangeEnvironments
	" 
	"   env : name of the new environment.
	"   label : if 1, then insert a \label at the end of the environment.
	"           otherwise, delete any \label line found.
	"   delete : a pattern which is to be deleted from the original environment.
	"            for example, going to a eqnarray* environment means we need to
	"            delete \label's.
	"   putInNonumber : whether we need to put a \nonumber before the end of the
	"                 environment.
	function! s:Change(env, label, delete, putInNonumber)

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

endif

" }}}
" Map <S-F1> through <S-F4> to insert environments {{{
if g:Tex_HotKeyMappings != ''

	" SetUpHotKeys: maps <F1> through <F4> to insert environments {{{
	" Description: 
	function! <SID>SetUpHotKeys()
		let i = 1
		let envname = Tex_Strntok(g:Tex_HotKeyMappings, ',', i)
		while  envname != ''

			exec 'inoremap <silent> <buffer> <S-F'.i.'> <C-r>=Tex_PutEnvironment("'.envname.'")<CR>'

			let i = i + 1
			let envname = Tex_Strntok(g:Tex_HotKeyMappings, ',', i)
			
		endwhile

	endfunction " }}}

endif

" }}}
" Tex_SetFastEnvironmentMaps: function for setting up the <F5> and <S-F1>-<S-F4> keys {{{
" Description: This function is made public so it can be called by the
"              SetTeXOptions() function in main.vim
function! Tex_SetFastEnvironmentMaps()
	if g:Tex_PromptedEnvironments != ''
		if !hasmapto('<Plug>Tex_FastEnvironmentInsert', 'i')
			imap <silent> <buffer> <F5> <Plug>Tex_FastEnvironmentInsert
		endif
		if !hasmapto('<Plug>Tex_FastEnvironmentInsert', 'n')
			nmap <silent> <buffer> <F5> <Plug>Tex_FastEnvironmentInsert
		endif
		if !hasmapto('<Plug>Tex_FastEnvironmentChange', 'i')
			imap <silent> <buffer> <S-F5> <Plug>Tex_FastEnvironmentChange
		endif
		if !hasmapto('<Plug>Tex_FastEnvironmentChange', 'n')
			nmap <silent> <buffer> <S-F5> <Plug>Tex_FastEnvironmentChange
		endif
		if !hasmapto('<Plug>Tex_FastEnvironmentInsert', 'v')
			vmap <silent> <buffer> <F5> <Plug>Tex_FastEnvironmentInsert
		endif
	endif
	if g:Tex_HotKeyMappings != ''
		call s:SetUpHotKeys()
	endif
endfunction " }}}

" this statement has to be at the end.
let s:doneOnce = 1

" vim:fdm=marker:nowrap:noet
