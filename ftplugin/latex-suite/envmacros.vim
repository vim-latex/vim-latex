"=============================================================================
" 	     File: envmacros.vim
"      Author: Mikolaj Machowski
"     Created: Tue Apr 23 08:00 PM 2002 PST
" Last Change: pon lis 04 09:00  2002 C
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
			call IMAP (a:lhs, "\\begin{".a:name."}\<CR>".extra."«»\<CR>\\end{".a:name."}«»", 'tex')
			exec 'vnoremap <silent> '.vlhs.' '.vrhs
		endif

	endif

	if g:Tex_Menus && g:Tex_EnvironmentMenus && has("gui_running")
		exe 'amenu '.location.' <plug><C-r>=Tex_MenuWizard("'.a:submenu.'", "'.a:name.'")<CR>'
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
		call IMAP (a:lhs, "\\".a:name."{«»}«»", 'tex')
	endif

	if g:Tex_Menus && g:Tex_SectionMenus
		let location = g:Tex_EnvMenuLocation.'Sections.'.a:name.'<tab>'.a:lhs.'\ ('.vlhs.')'
		let advlocation = g:Tex_EnvMenuLocation.'Sections.Advanced.'.a:name

		let irhs = "\<C-r>=IMAP_PutTextWithMovement('\\".a:name."{«»}«»')\<CR>"

		let advirhs = "\<C-r>=Tex_InsSecAdv('".a:name."')\<CR>"
		let advvrhs = "\<C-\\>\<C-N>:call Tex_VisSecAdv('".a:name."')\<CR>"

		exe 'amenu '.advlocation." <plug>".advirhs
		exe 'vnoremenu '.advlocation." ".advvrhs

		exe 'amenu '.location." <plug>".irhs
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
call s:Tex_SpecialMacros("ELI", '&Lists.',  'list', "\\begin{list}{«label»}{«commands»}\<cr>\\item «»\<cr>\\end{list}«»")
call s:Tex_EnvMacros('EEN', '&Lists.', 'enumerate')
call s:Tex_EnvMacros('EIT', '&Lists.', 'itemize')
call s:Tex_EnvMacros('ETI', '&Lists.', 'theindex')
call s:Tex_EnvMacros('ETL', '&Lists.', 'trivlist')
" }}}
" Tables {{{
call s:Tex_SpecialMacros("ETE", '&Tables.', 'table', "\\begin{table}\<cr>\\centering\<cr>\\caption{tab:ä}\<cr>\\begin{tabular}{«dimensions»}\<cr>«»\<cr>\\end{tabular}\<cr>\\label{tab:«label»}\<cr>\\end{table}«»")
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
call s:Tex_SpecialMacros("EAR", 'Math.', 'array', "\\leftä\<cr>\\begin{array}{«dimension»}\<cr>«elements»\<cr>\\end{array}\<cr>\\right«»")
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
call s:Tex_SpecialMacros("EFI", '', 'figure', "\\begin{figure}[«htpb»]\<cr>\\centerline{\\psfig{figure=«eps file»}}\<cr>\\caption{«caption text»}\<cr>\\label{fig:«label»}\<cr>\\end{figure}«»")
call s:Tex_EnvMacros('', '', 'figure*')
call s:Tex_EnvMacros('ELR', '', 'lrbox')
call s:Tex_SpecialMacros("EMP", '', 'minipage', "\\begin{minipage}[«tb»]{«width»}\<cr>«»\<cr>\\end{minipage}«»")
call s:Tex_SpecialMacros("EPI", '', 'picture', "\\begin{picture}(«width», «height»)(«xoff»,«yoff»)\<cr>\\put(«xoff»,«yoff»){\\framebox(«»,«»){«»}}\<cr>\\end{picture}«»")
" }}}

if g:Tex_CatchVisMapErrors
	exe "vnoremap ".g:Tex_Leader2."   :\<C-u>call ExecMap('".g:Tex_Leader2."', 'v')\<CR>"
endif

" this statement has to be at the end.
let s:doneOnce = 1

" vim:fdm=marker:nowrap:noet
