"=============================================================================
" 	     File: packages.vim
"      Author: Mikolaj Machowski
" 	  Version: 1.0 
"     Created: Tue Apr 23 06:00 PM 2002 PST
" Last Change: czw maj 09 11:00  2002 U
" 
"  Description: handling packages from within vim
"=============================================================================

" avoid reinclusion.
if !g:Tex_PackagesMenu || exists('s:doneOnce')
	finish
endif
let s:doneOnce = 1

" Level of Packages menu: 
let s:p_menu_lev = g:Tex_PackagesMenuLocation

let s:path = expand("<sfile>:p:h")
let s:menu_div = "20"

com! -nargs=* TPackage call Tex_pack_one(<f-args>)
com! -nargs=0 TPackageUpdate :silent! call Tex_pack_one(expand("<cword>"))
com! -nargs=0 TPackageUpdateAll :silent! call Tex_pack_updateall()

let g:Tex_package_supported = ""
let g:Tex_package_detected = ""

" Tex_pack_check: creates the package menu and adds to 'dict' setting. {{{
"
function! Tex_pack_check(package)
	if has("gui_running") && filereadable(s:path."/packages/".a:package)
		call TeX_pack(a:package)
		let g:Tex_package_supported = g:Tex_package_supported.",".a:package
	endif
	if filereadable(s:path.'/dictionaries/'.a:package)
		exe 'setlocal dict+='.s:path.'/dictionaries/'.a:package
		if !has("gui_running") && filereadable(s:path."/dictionaries/".a:package)
			let g:Tex_package_supported = g:Tex_package_supported.",".a:package
		endif
	endif
	let g:Tex_package_supported = substitute(g:Tex_package_supported, "^,", "", "")
endfunction

" }}}
" Tex_pack_uncheck: removes package from menu and 'dict' settings. {{{
function! Tex_pack_uncheck(package)
	if has("gui") && filereadable(s:path."/packages/".a:package)
		exe "aunmenu ".s:p_menu_lev."&".a:package
	endif
	if filereadable(s:path.'/dictionaries/'.a:package)
		exe 'setlocal dict-='.s:path.'/dictionaries/'.a:package
	endif
endfunction

" }}}
" Tex_pack_updateall: {{{
function! Tex_pack_updateall()
	if exists("g:Tex_package_supported")
		let i = 1
		while 1
			let old_pack_name = Tex_Strntok(g:Tex_package_supported, ",", i)
			if old_pack_name == ""
				break
			endif
			call Tex_pack_uncheck(old_pack_name)
			let i = i + 1
		endwhile
		let g:Tex_package_supported = ""
		let g:Tex_package_detected = ""
		call TeX_pack_all()
	else
		call TeX_pack_all()
	endif
endfunction

" }}}
" Tex_pack_one: {{{
function! Tex_pack_one(...)
	if a:0 == 0
		let pwd = getcwd()
		exe 'cd '.s:path.'/packages'
		let filename = Tex_ChooseFile('Choose a package:')
		exe 'cd '.pwd
	else
		let i = a:0
		let omega = 1
		while omega <= i
			exe "let packname = a:".omega
			call Tex_pack_check(packname)
			let omega = omega + 1
		endwhile
	endif
endfunction
" }}}
" TeX_pack_all: scans the current file for \\usepackage{ lines {{{
"               and loads the corresponding package options as menus.
function! TeX_pack_all()

	let pos = line('.').' | normal! '.virtcol('.').'|'

	if Tex_GetMainFileName() != ''
		let cwd = getcwd()
		let fname = Tex_GetMainFileName()
		if glob(fname.'.tex') != ''
			let fname = fname.'.tex'
		elseif glob(fname) != ''
			let fname = ''
		else
			let fname = expand('%:p')
		endif
	else
		let fname = expand('%:p')
	endif

	let toquit = 0
	if fname != expand('%:p')
		exe 'split '.fname
		let toquit = 1
	endif

	exe 0
	let beginline = search('\\begin{document}', 'W')
	exe 0
	let oldpack = ""
	let packname = ""
	while search('usepackage.*', 'W')
		if line(".") > beginline 
			break
		elseif getline(".") =~ "^\s*%"
			continue
		elseif getline(".") =~ "^[^%]\\{-}\\\\usepackage[^{]\\{-}[%$]"
			let packname = matchstr(getline(search('^[^%]\{-}\]{', 'W')), '^.\{-}\]{\zs[^}]*\ze}')
		elseif getline(".") =~ "^[^%]\\{-}\\\\usepackage"
			let packname = matchstr(getline("."), '^[^%]\{-}usepackage.\{-}{\zs[^}]*\ze}')
		endif
		let packname = substitute(packname, "\\s", "", "g")
		if packname =~ ","
			let i = 1
			while 1
				let pname = Tex_Strntok(packname, ",", i)
				if pname == ''
					break
				endif
				let g:Tex_package_detected = g:Tex_package_detected." ".pname
				call Tex_pack_check(pname)
				let i = i + 1
			endwhile
		elseif oldpack != packname
			let g:Tex_package_detected = g:Tex_package_detected." ".packname
			call Tex_pack_check(packname)
		endif
		let oldpack = packname
	endwhile

	if toquit
		q	
	endif
	exe pos
endfunction
   
" }}}
" TeX_pack_supp_menu: sets up a menu for packages found in packages/ {{{
"                     groups the packages thus found into groups of 20...
function! TeX_pack_supp_menu()
	let g:suplist = glob(s:path."/packages/*")
	let g:suplist = substitute(g:suplist, "\n", ",", "g")
	let nu_s_list = GetListCount(g:suplist)
		if nu_s_list <= s:menu_div
			let SupMenu = ""
			let NotSupMenu = "1"
		endif
	let basic_nu_s_list = "0"
	let OptMenu = ""
	while basic_nu_s_list < nu_s_list
		let s_item = GetListItem(g:suplist, basic_nu_s_list)
		let fptr = fnamemodify(s_item, ':p:t:r')
		let fpt = fnamemodify(s_item, ':p:t')
		if !exists("NotSupMenu") && basic_nu_s_list % s:menu_div == 0 
			let s_index = strpart(fptr, 0, 5)
			if strlen(s_item) > 5
				let OptMenu = ".".s_index."\\.\\.\\.\\ -"
			else
				let OptMenu = ".".s_index."\\ -" 
			endif
		endif
		exe "amenu ".s:p_menu_lev."&Supported".OptMenu.".&".fptr." :call TeX_pack_supp('".fpt."')<CR>"
		let basic_nu_s_list = basic_nu_s_list + 1
	endwhile
endfunction 

" }}}
" TeX_pack: loads the options (and commands) for the given package {{{
function! TeX_pack(pack)
	let basic_nu_p_list = ""
	let nu_p_list = "" 
	let g:p_file = s:path . "/packages/" . a:pack
	if filereadable(g:p_file)
		exe "source " . g:p_file
		exe "let g:p_list = g:TeX_package_" . a:pack 
		exe "let g:p_o_list = g:TeX_package_option_" . a:pack 

		" Creating package.Option menu {{{
		if exists("g:p_o_list") && g:p_o_list != ""
			let nu_p_o_list = GetListCount(g:p_o_list)
			if nu_p_o_list <= s:menu_div
				let OptMenu = ""
				let NotOptMenu = "1"
			endif
			if nu_p_o_list == "1"
				let p_o_delimiter = ""
			else
				let p_o_delimiter = ","
			endif
			let basic_nu_p_o_list = 0
			let o_loop_nu = 0
			while basic_nu_p_o_list < nu_p_o_list
				let p_o_item = GetListItem(g:p_o_list, basic_nu_p_o_list)
				let p_o_item_def = strpart(p_o_item, 0, 3)
				let p_o_item_name = substitute(p_o_item, "^...:", "", "")
				if !exists("NotOptMenu") && (o_loop_nu % s:menu_div == 0 || p_o_item_def == "sbr")
					if p_o_item_def == "sbr"
						let OptMenu = ".&".p_o_item_name
						let o_loop_nu = 1
						let basic_nu_p_o_list = basic_nu_p_o_list + 1
						let p_o_item = GetListItem(g:p_o_list, basic_nu_p_o_list)
					else
						let ost_index = strpart(p_o_item_name, 0, 4)
						if strlen(p_o_item_name) > 5
							let OptMenu = ".".ost_index."\\.\\.\\.\\ -"
						else
							let OptMenu = ".".ost_index."\\ -" 
						endif
					endif
				endif
				let l_m_p_o_item = "&".substitute(p_o_item, "ä", "", "")
				let p_o_end = p_o_item[strlen(p_o_item)-1]
				if p_o_end !~ "[a-zA-Z}]"
					let r_m_p_o_item = "<plug><C-r>=IMAP_PutTextWithMovement('".p_o_item."ä".p_o_delimiter."«»')<cr>"
				elseif p_o_end == "}"
					let r_m_p_o_item = "<plug><C-r>=IMAP_PutTextWithMovement('".p_o_item.p_o_delimiter."«»')<cr>"
				else
					let r_m_p_o_item = "<plug>".p_o_item.p_o_delimiter
				endif
				exe "amenu ".s:p_menu_lev."&".a:pack.".&Options".OptMenu.".".l_m_p_o_item." ".r_m_p_o_item
				let basic_nu_p_o_list = basic_nu_p_o_list + 1
				let o_loop_nu = o_loop_nu + 1
			endwhile
		endif  " }}}
		" Creating package.Command menu {{{
		let nu_p_list = GetListCount(g:p_list)
		if nu_p_list <= s:menu_div
			let ComMenu = ""
			let NotComMenu = "1"
		endif
		let basic_nu_p_list = 0
		let loop_nu = 0
		while basic_nu_p_list < nu_p_list
			let p_item = GetListItem(g:p_list, basic_nu_p_list)
			let p_item_def = strpart(p_item, 0, 3)
			let p_item_name = substitute(p_item, "^...:", "", "")
			if !exists("NotComMenu") && p_item_def == "sbr"
				let ComMenu = ".&".p_item_name
				let loop_nu = 1
				let basic_nu_p_list = basic_nu_p_list + 1
				let p_item = GetListItem(g:p_list, basic_nu_p_list)
				let p_item_def = strpart(p_item, 0, 3)
				let p_item_name = substitute(p_item, "^...:", "", "")
			endif
			" testing command type {{{
			if p_item_def == "bra"
				let com_type = "{}"
				let l_m_item = "\\\\&".p_item_name."{}"
				let r_m_item = "<plug><C-r>=IMAP_PutTextWithMovement('\\".p_item_name."{ä}«»')<cr>"
			elseif p_item_def == "brs" 
				let com_type = "{}"
				let l_m_item = "\\\\&".substitute(p_item_name, "[ä«»]", "", "g")
				let r_m_item = "<plug><C-r>=IMAP_PutTextWithMovement('\\".p_item_name."«»')<cr>"
			elseif p_item_def == "brd"
				let com_type = "{}{}"
				let l_m_item = "\\\\&".p_item_name."{}{}"
				let r_m_item = "<plug><C-r>=IMAP_PutTextWithMovement('\\".p_item_name."{ä}{«»}«»')<cr>"
			elseif p_item_def == "sep"
				let com_type = ""
				let l_m_item = "-packsep".basic_nu_p_list."-"
				let r_m_item = ":"
			elseif p_item_def == "env"
				let com_type = "(E)"
				let l_m_item = "&".p_item_name."(E)"
				let r_m_item = "<plug>\\begin{".p_item_name."}<cr> <cr>\\end{".p_item_name."}«»<Up><Left>"
			elseif p_item_def == "ens"
				let com_type = "(E)"
				let p_env_spec = substitute(p_item_name, ".*:", "", "")
				let p_env_name = matchstr(p_item_name, "^[^:]*")
				let l_m_item = "&".p_env_name."(E)"
				let r_m_item = "<plug>\\begin{".p_env_name."}".p_env_spec."<cr>«»<cr>\\end{".p_env_name."}«»<Up><Up><C-j>"
			elseif p_item_def == "eno"
				let com_type = "(E)"
				let l_m_item = "&".p_item_name."(E)"
				let r_m_item = "<plug>\\begin[«»]{".p_item_name."}<cr>«»<cr>\\end{".p_item_name."}«»<Up><Up><C-j>"
			elseif p_item_def == "nor"
				let com_type = "\\\\'"
				let l_m_item = "\\\\&".p_item_name."'"
				let r_m_item = "<plug>\\".p_item_name." "
			elseif p_item_def == "noo"
				let com_type = "\\\\[]"
				let l_m_item = "\\\\&".p_item_name."[]"
				let r_m_item = "<plug><C-r>=IMAP_PutTextWithMovement('\\".p_item_name."[ä]«»')<cr>"
			elseif p_item_def == "nob"
				let com_type = "[]{}"
				let l_m_item = "\\\\&".p_item_name."[]{}"
				let r_m_item = "<plug><C-r>=IMAP_PutTextWithMovement('\\".p_item_name."[ä]{«»}«»')<cr>"
			elseif p_item_def == "pla"
				let com_type = "(p)"
				let l_m_item = "&".p_item_name."'"
				let r_m_item = "<plug>".p_item_name." "
			elseif p_item_def == "spe"
				let com_type = "(s)"
				let l_m_item = "&".p_item_name
				let r_m_item = "<plug>".p_item_name
			else
				let com_type = "\\\\"
				let l_m_item = "\\\\&".p_item_name
				let r_m_item = "<plug>\\".p_item_name
			endif " }}}
			if !exists("NotComMenu") && loop_nu % s:menu_div == 0
				let st_index = strpart(p_item_name, 0, 4)
				if strlen(p_item_name) > 4
					let ComMenu = ".".com_type."&".st_index."\\.\\.\\.\\ -"
				else
					let ComMenu = ".".com_type."&".st_index."\\ -" 
				endif
			endif
			exe "amenu ".s:p_menu_lev."&".a:pack.ComMenu.".".l_m_item." ".r_m_item 
			let basic_nu_p_list = basic_nu_p_list + 1
			let loop_nu = loop_nu + 1
		endwhile " }}}

	endif
endfunction 

" }}}
" TeX_pack_supp: "supports" the package... {{{
function! TeX_pack_supp(supp_pack)
	call TeX_pack(a:supp_pack)
	exe "let g:s_p_o = g:TeX_package_option_".a:supp_pack 
	if exists("g:s_p_o") && g:s_p_o != ""
		exe "normal i\\usepackage{".a:supp_pack."}«»"
		exe "normal F{i[]\<Right>"
	else
		exe "normal i\\usepackage{".a:supp_pack."}\<cr>"
	endif
endfunction

" }}}

if g:Tex_Menus
	exe "amenu ".s:p_menu_lev."&Update :call TeX_pack(expand('<cword>'))<cr>"
	exe "amenu ".s:p_menu_lev."&UpdateAll :call Tex_pack_updateall()<cr>"
endif

if g:Tex_Menus
	call TeX_pack_supp_menu()
	call TeX_pack_all()
endif

" vim:fdm=marker:ts=4:sw=4:noet
