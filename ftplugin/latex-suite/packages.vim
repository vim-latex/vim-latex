"=============================================================================
" 	     File: packages.vim
"      Author: Mikolaj Machowski
"     Created: Tue Apr 23 06:00 PM 2002 PST
" Last Change: Fri Dec 27 02:00 PM 2002 PST
" 
"  Description: handling packages from within vim
"=============================================================================

" avoid reinclusion.
if !g:Tex_PackagesMenu || exists('s:doneOnce')
	finish
endif
let s:doneOnce = 1

let s:path = expand("<sfile>:p:h")

let s:menu_div = 20

com! -nargs=* TPackage :normal! i<C-r>=Tex_pack_one(<f-args>)<CR>
com! -nargs=0 TPackageUpdate :silent! call Tex_pack_updateall()
com! -nargs=0 TPackageUpdateAll :silent! call Tex_pack_updateall()

imap <silent> <plug> <Nop>
nmap <silent> <plug> i

let g:Tex_package_supported = ''
let g:Tex_package_detected = ''

" Tex_pack_check: creates the package menu and adds to 'dict' setting. {{{
"
function! Tex_pack_check(package)
	if filereadable(s:path.'/packages/'.a:package)
		exe 'source ' . s:path . '/packages/' . a:package
		if has("gui_running")
			call Tex_pack(a:package)
		endif
		let g:Tex_package_supported = g:Tex_package_supported.','.a:package
	endif
	if filereadable(s:path.'/dictionaries/'.a:package)
		exe 'setlocal dict+='.s:path.'/dictionaries/'.a:package
		if !has("gui_running") && filereadable(s:path.'/dictionaries/'.a:package)
				\ && g:Tex_package_supported !~ a:package
			let g:Tex_package_supported = g:Tex_package_supported.','.a:package
		endif
	endif
	let g:Tex_package_supported = substitute(g:Tex_package_supported, '^,', '', '')
endfunction

" }}}
" Tex_pack_uncheck: removes package from menu and 'dict' settings. {{{
function! Tex_pack_uncheck(package)
	if has("gui_running") && filereadable(s:path.'/packages/'.a:package)
		exe 'silent! aunmenu '.g:Tex_PackagesMenuLocation.'-sep'.a:package.'-'
		exe 'silent! aunmenu '.g:Tex_PackagesMenuLocation.a:package.'\ Options'
		exe 'silent! aunmenu '.g:Tex_PackagesMenuLocation.a:package.'\ Commands'
	endif
	if filereadable(s:path.'/dictionaries/'.a:package)
		exe 'setlocal dict-='.s:path.'/dictionaries/'.a:package
	endif
endfunction

" }}}
" Tex_pack_updateall: updates the TeX-Packages menu {{{
function! Tex_pack_updateall()
	if exists('g:Tex_package_supported')
		let i = 1
		while 1
			let old_pack_name = Tex_Strntok(g:Tex_package_supported, ',', i)
			if old_pack_name == ''
				break
			endif
			call Tex_pack_uncheck(old_pack_name)
			let i = i + 1
		endwhile
		let g:Tex_package_supported = ''
		let g:Tex_package_detected = ''
		call Tex_pack_all()
	else
		call Tex_pack_all()
	endif
endfunction

" }}}
" Tex_pack_one: supports each package in the argument list.{{{
" Description:
"   If no arguments are supplied, then the user is asked to choose from the
"   packages found in the packages/ directory
function! Tex_pack_one(...)
	if a:0 == 0 || (a:0 > 0 && a:1 == '')
		let pwd = getcwd()
		exe 'cd '.s:path.'/packages'
		let packname = Tex_ChooseFile('Choose a package: ')
		exe 'cd '.pwd
		if packname != ''
			return Tex_pack_one(packname)
		else
			return ''
		endif
	else
		" Support the packages supplied. This function can be called with
		" multiple arguments in which case, support each of them in turn.
		let retVal = ''
		let omega = 1
		while omega <= a:0
			let packname = a:{omega}
			if filereadable(s:path.'/packages/'.packname)
				call Tex_pack_check(packname)
				if exists('g:TeX_package_option_'.packname)
						\ && g:TeX_package_option_{packname} != ''
					let retVal = retVal.'\usepackage[<++>]{'.packname.'}<++>'
				else
					let retVal = retVal.'\usepackage{'.packname.'}'."\<CR>"
				endif
			else
				let retVal = retVal.'\usepackage{'.packname.'}'."\<CR>"
			endif
			let omega = omega + 1
		endwhile
		return IMAP_PutTextWithMovement(substitute(retVal, "\<CR>$", '', ''), '<+', '+>')
	endif
endfunction
" }}}
" Tex_pack_all: scans the current file for \usepackage{} lines {{{
"   and if supported, loads the options and commands found in the
"   corresponding package file.
function! Tex_pack_all()

	let pos = line('.').' | normal! '.virtcol('.').'|'
	let currfile = expand('%:p')

	if Tex_GetMainFileName() != ''
		let fname = Tex_GetMainFileName(':p:r')
	else
		let fname = currfile
	endif

	let toquit = 0
	if fname != currfile
		exe 'split '.fname
		let toquit = 1
	endif

	exe 0
	let beginline = search('\\begin{document}', 'W')
	exe 0
	let oldpack = ''
	let packname = ''
	while search('usepackage.*', 'W')
		if line('.') > beginline 
			break
		elseif getline('.') =~ '^\s*%'
			continue
		elseif getline('.') =~ '^[^%]\{-}\\usepackage[^{]\{-}[%$]'
			let packname = matchstr(getline(search('^[^%]\{-}\]{', 'W')), '^.\{-}\]{\zs[^}]*\ze}')
		elseif getline('.') =~ '^[^%]\{-}\\usepackage'
			let packname = matchstr(getline("."), '^[^%]\{-}usepackage.\{-}{\zs[^}]*\ze}')
		endif
		let packname = substitute(packname, '\s', '', 'g')
		if packname =~ ','
			let i = 1
			while 1
				let pname = Tex_Strntok(packname, ',', i)
				if pname == ''
					break
				endif
				let g:Tex_package_detected = g:Tex_package_detected.' '.pname
				call Tex_pack_one(pname)
				let i = i + 1
			endwhile
		elseif oldpack != packname
			let g:Tex_package_detected = g:Tex_package_detected.' '.packname
			call Tex_pack_one(packname)
		endif
		let oldpack = packname
	endwhile

	if toquit
		q	
	endif
	exe pos
endfunction
   
" }}}
" Tex_pack_supp_menu: sets up a menu for package files {{{
"   found in the packages directory groups the packages thus found into groups
"   of 20...
function! Tex_pack_supp_menu()

	let pwd = getcwd()
	exec 'cd '.s:path.'/packages'
	let suplist = glob("*")
	exec 'cd '.pwd

	let suplist = substitute(suplist, "\n", ',', 'g').','

	call Tex_MakeSubmenu(suplist, g:Tex_PackagesMenuLocation.'Supported.', 
		\ '<plug><C-r>=Tex_pack_one("', '")<CR>')
endfunction 

" }}}
" Tex_pack: loads the options (and commands) for the given package {{{
function! Tex_pack(pack)
	if exists('g:TeX_package_'.a:pack)

		exec 'amenu '.g:Tex_PackagesMenuLocation.'-sep'.a:pack.'- <Nop>'
		let optionList = g:TeX_package_option_{a:pack}.','

		if optionList != ''

			let mainMenuName = g:Tex_PackagesMenuLocation.a:pack.'\ Options.'
			call s:GroupPackageMenuItems(optionList, mainMenuName, 
				\ '<plug><C-r>=IMAP_PutTextWithMovement("', ',")<CR>')

		endif

		let commandList = g:TeX_package_{a:pack}
		if commandList != ''

			let mainMenuName = g:Tex_PackagesMenuLocation.a:pack.'\ Commands.'
			call s:GroupPackageMenuItems(commandList, mainMenuName, 
				\ '<plug><C-r>=Tex_ProcessPackageCommand("', '")<CR>',
				\ '<SID>FilterPackageMenuLHS')
		endif
	endif
endfunction 

" }}}

" ==============================================================================
" Menu Functions
" Creating menu items for the all the package files found in the packages/
" directory as well as creating menus for each supported package found in the
" preamble.
" ============================================================================== 
" Tex_MakeSubmenu: makes a submenu given a list of items {{{
" Description: 
"   This function takes a comma seperated list of menu items and creates a
"   'grouped' menu. i.e, it groups the items into s:menu_div items each and
"   puts them in submenus of the given mainMenu.
"   Each menu item is linked to the HandlerFunc.
"   If an additional argument is supplied, then it is used to filter each of
"   the menu items to generate better names for the menu display.
"
function! Tex_MakeSubmenu(menuList, mainMenuName, 
				\ handlerFuncLHS, handlerFuncRHS, ...)

	let extractFunction = (a:0 > 0 ? a:1 : '' )
	let menuList = substitute(a:menuList, '[^,]$', ',', '')

	let doneMenuSubmenu = 0

	while menuList != ''

		" Extract upto s:menu_div menus at once.
		let menuBunch = matchstr(menuList, '\v(.{-},){,'.s:menu_div.'}')

		" The remaining menus go into the list.
		let menuList = strpart(menuList, strlen(menuBunch))

		let submenu = ''
		" If there is something remaining, then we got s:menu_div items.
		" therefore put these menu items into a submenu.
		if strlen(menuList) || doneMenuSubmenu
			exec 'let firstMenu = '.extractFunction."(matchstr(menuBunch, '\\v^.{-}\\ze,'))"
			exec 'let lastMenu = '.extractFunction."(matchstr(menuBunch, '\\v[^,]{-}\\ze,$'))"

			let submenu = firstMenu.'\ \-\ '.lastMenu.'.'

			let doneMenuSubmenu = 1
		endif

		" Now for each menu create a menu under the submenu
		let i = 1
		let menuName = Tex_Strntok(menuBunch, ',', i)
		while menuName != ''
			exec 'let menuItem = '.extractFunction.'(menuName)'
			execute 'amenu '.a:mainMenuName.submenu.menuItem
				\ '       '.a:handlerFuncLHS.menuName.a:handlerFuncRHS

			let i = i + 1
			let menuName = Tex_Strntok(menuBunch, ',', i)
		endwhile
	endwhile
endfunction 

" }}}
" GroupPackageMenuItems: uses the sbr: to split menus into groups {{{
" Description: 
"   This function first splits up the menuList into groups based on the
"   special sbr: tag and then calls Tex_MakeSubmenu 
" 
function! <SID>GroupPackageMenuItems(menuList, menuName, 
					\ handlerFuncLHS, handlerFuncRHS,...)

	if a:0 > 0
		let extractFunction = a:1
	else
		let extractFunction = ''
	endif
	let menuList = a:menuList

	while matchstr(menuList, 'sbr:') != ''
		let groupName = matchstr(menuList, '\v^sbr:\zs.{-}\ze,')
		let menuList = strpart(menuList, strlen('sbr:'.groupName.','))
		if matchstr(menuList, 'sbr:') != ''
			let menuGroup = matchstr(menuList, '\v^.{-},\zesbr:')
		else
			let menuGroup = menuList
		endif

		call Tex_MakeSubmenu(menuGroup, a:menuName.groupName.'.', 
			\ a:handlerFuncLHS, a:handlerFuncRHS, extractFunction)

		let menuList = strpart(menuList, strlen(menuGroup))
	endwhile

	call Tex_MakeSubmenu(menuList, a:menuName,
		\ a:handlerFuncLHS, a:handlerFuncRHS, extractFunction)

endfunction " }}}
" Definition of what to do for various package commands {{{
let s:CommandSpec_bra = '\<+replace+>{<++>}<++>'
let s:CommandSpec_brs = '\<+replace+><++>'
let s:CommandSpec_brd = '\<+replace+>{<++>}{<++>}<++>'
let s:CommandSpec_env = '\begin{<+replace+>}'."\<CR><++>\<CR>".'\end{<+replace+>}<++>'
let s:CommandSpec_ens = '\begin{<+replace+>}<+extra+>'."\<CR><++>\<CR>".'\end{<+replace+>}<++>'
let s:CommandSpec_eno = '\begin[<++>]{<+replace+>}'."\<CR><++>\<CR>".'\end{<+replace+>}'
let s:CommandSpec_nor = '\<+replace+>'
let s:CommandSpec_noo = '\<+replace+>[<++>]'
let s:CommandSpec_nob = '\<+replace+>[<++>]{<++>}{<++>}<++>'
let s:CommandSpec_spe = '<+replace+>'
let s:CommandSpec_    = '\<+replace+>'

let s:MenuLHS_bra = '\\&<+replace+>{}'
let s:MenuLHS_brs = '\\&<+replace+>{}'
let s:MenuLHS_brd = '\\&<+replace+>{}{}'
let s:MenuLHS_env = '&<+replace+>\ (E)'
let s:MenuLHS_ens = '&<+replace+>\ (E)'
let s:MenuLHS_eno = '&<+replace+>\ (E)'
let s:MenuLHS_nor = '\\&<+replace+>'
let s:MenuLHS_noo = '\\&<+replace+>[]'
let s:MenuLHS_nob = '\\&<+replace+>[]{}{}'
let s:MenuLHS_spe = '&<+replace+>'
let s:MenuLHS_sep = '-sep<+replace+>-'
let s:MenuLHS_    = '\\&<+replace+>'
" }}}
" Tex_ProcessPackageCommand: processes a command from the package menu {{{
" Description: 
function! Tex_ProcessPackageCommand(command)
	if a:command =~ ':'
		let commandType = matchstr(a:command, '^\w\+\ze:')
		let commandName = matchstr(a:command, '^\w\+:\zs[^:]\+\ze:\?')
		let extrapart = strpart(a:command, strlen(commandType.':'.commandName.':'))
	else
		let commandType = ''
		let commandName = a:command
		let extrapart = ''
	endif

	let command = s:CommandSpec_{commandType}
	let command = substitute(command, '<+replace+>', commandName, 'g')
	let command = substitute(command, '<+extra+>', extrapart, 'g')
	return IMAP_PutTextWithMovement(command)
endfunction 
" }}}
" FilterPackageMenuLHS: filters the command description to provide a better menu item {{{
" Description: 
function! <SID>FilterPackageMenuLHS(command)
	let commandType = matchstr(a:command, '^\w\+\ze:')
	if commandType != ''
		let commandName = strpart(a:command, strlen(commandType.':'))
	else
		let commandName = a:command
	endif

	return substitute(s:MenuLHS_{commandType}, '<+replace+>', commandName, 'g')
endfunction " }}}

if g:Tex_Menus
	exe 'amenu '.g:Tex_PackagesMenuLocation.'&UpdatePackage :call Tex_pack(expand("<cword>"))<cr>'
	exe 'amenu '.g:Tex_PackagesMenuLocation.'&UpdateAll :call Tex_pack_updateall()<cr>'

 	call Tex_pack_supp_menu()
 	call Tex_pack_all()

endif

" vim:fdm=marker:ts=4:sw=4:noet:fo-=wa1
