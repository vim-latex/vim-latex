
" RemoteOpen: open a file remotely (if possible) {{{
" Description: checks all open vim windows to see if this file has been opened
"              anywhere and if so, opens it there instead of in this session.
function! latexsuite#remoteopen#RemoteOpen(arglist)

	" First construct line number and filename from argument. a:arglist is of
	" the form:
	"    +10 c:\path\to\file
	" or just
	" 	 c:\path\to\file
	if a:arglist =~ '^\s*+\d\+'
		let linenum = matchstr(a:arglist, '^\s*+\zs\d\+\ze')
		let filename = matchstr(a:arglist, '^\s*+\d\+\s*\zs.*\ze')
	else
		let linenum = 1
		let filename = matchstr(a:arglist, '^\s*\zs.*\ze')
	endif
	let filename = escape(filename, ' ')
	call Tex_Debug("linenum = ".linenum.', filename = '.filename, "ropen")

	" If there is no clientserver functionality, then just open in the present
	" session and return
	if !has('clientserver')
		call Tex_Debug("-clientserver, opening locally and returning", "ropen")
		exec "e ".filename
		exec linenum
		normal! zv
		return
	endif

	" Otherwise, loop through all available servers
	let servers = serverlist()
	" If there are no servers, open file locally.
	if servers == ''
		call Tex_Debug("no open servers, opening locally", "ropen")
		exec "e ".filename
		exec linenum
		let g:Remote_Server = 1
		normal! zv
		return
	endif

	let i = 1
	let server = s:Strntok(servers, "\n", i)
	let targetServer = v:servername

	while server != ''
		" Find out if there was any server which was used by remoteOpen before
		" this. If a new gvim session was ever started via remoteOpen, then
		" g:Remote_Server will be set.
		if remote_expr(server, 'exists("g:Remote_Server")')
			let targetServer = server
		endif

		" Ask each server if that file is being edited by them.
		let bufnum = remote_expr(server, "bufnr('".filename."')")
		" If it is...
		if bufnum != -1
			" ask the server to edit that file and come to the foreground.
			" set a variable g:Remote_Server to indicate that this server
			" session has at least one file opened via RemoteOpen
			let targetServer = server
			break
		end

		let i = i + 1
		let server = s:Strntok(servers, "\n", i)
	endwhile

	" If none of the servers have the file open, then open this file in the
	" first server. This has the advantage if yap tries to make vim open
	" multiple vims, then at least they will all be opened by the same gvim
	" server.
	call remote_send(targetServer,
		\ "\<C-\>\<C-n>".
		\ ":let g:Remote_Server = 1\<CR>".
		\ ":drop ".filename."\<CR>".
		\ ":".linenum."\<CR>zv"
		\ )
	call remote_foreground(targetServer)
	" quit this vim session
	if v:servername != targetServer
		q
	endif
endfunction " }}}
" RemoteInsert: inserts a \cite'ation remotely (if possible) {{{
" Description:
function! latexsuite#remoteopen#RemoteInsert(...)

	let citation =  matchstr(argv(0), "\\[InsText('.cite{\\zs.\\{-}\\ze}');\\]")
	if citation == ""
		q
	endif

	" Otherwise, loop through all available servers
	let servers = serverlist()

	let i = 1
	let server = s:Strntok(servers, "\n", i)
	let targetServer = v:servername

	while server != ''
		if remote_expr(server, 'exists("g:Remote_WaitingForCite")')
			call remote_send(server, citation . "\<CR>")
			call remote_foreground(server)
			if v:servername != server
				q
			else
				return
			endif
		endif

		let i = i + 1
		let server = s:Strntok(servers, "\n", i)
	endwhile

	q

endfunction " }}}
" Strntok: extract the n^th token from a list {{{
" example: Strntok('1,23,3', ',', 2) = 23
fun! s:Strntok(s, tok, n)
	return matchstr( a:s.a:tok[0], '\v(\zs([^'.a:tok.']*)\ze['.a:tok.']){'.a:n.'}')
endfun

" }}}

" vim:ft=vim:ts=4:sw=4:noet:fdm=marker:commentstring=\"\ %s:nowrap
