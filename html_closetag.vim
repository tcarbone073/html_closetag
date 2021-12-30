" Global flag to toggle debug mode (i.e., echoing variables)
let s:debug = 0

fun! s:Init()

	" If '<' is pressed, autocomplete closing tag and move cursor within tag	
	autocmd BufNewFile,BufRead *.html inoremap <lt> <lt>><left>

	" If <Tab> is pressed, go to handling function
	au Filetype html inoremap <silent> <Tab> <Esc>:call <SID>OnTabPress()<Cr>

	" If <Return> is prssed, go to handing function
	au filetype html inoremap <silent> <Cr> <Esc>:call <SID>OnReturnPress()<Cr>

endf

fun! s:InsideOpenTag()
	" Returns 1 if the cursor is between two carrots ('<>'), 0 if not.
	
	" Note, because we entered '<Esc>' before the function call (i.e., exiting
	" insert mode), the cursor was moved left one column. So we actually need
	" to check if the cursor is one position to the left of the closing carrot
	" ('>').
	if getline('.')[col('.')] == '>' | retu 1 | el | retu 0 | en
endf


fun! s:GetTag()
	" Returns the text within the opening HTML tag, only up to the first space,
	" ignoring any attributes that follow.
	"
	" Ex:	If the line is '<head>', returns 'head'.
	" 		If the line is '<a href="someurl"', returns 'a'
	
	" Get the entire current line.
	let l:line = getline('.')
	if s:debug | echom "Line is: '" . l:line . "'" | en
	
	" Get the 0-based indices of the start and end of the entire string that is
	" between the carrots ('<>').
	let l:start = stridx(l:line, "<")+1
	let l:end = stridx(l:line, ">")-1
	if s:debug | echom "Tag start/end is: '" . l:start . "/" . l:end . "'" | en

	" Get the string that is between the carrots ('<>')
	let l:element = strpart(l:line, l:start, l:end - l:start + 1)
	if s:debug | echom "Element is: '" . l:element . "'" | en

	" Ignore the HTML attribute (e.g., <a href=...>)
	let l:tagname = split(l:element)[0]
	retu l:tagname
endf


fun! s:IsValidTag(tagname)
	" Return 1 if `tag` is a valid html tag, 0 if not.	
	retu 1
endf


fun! s:IsPairedTag(tagname)
	" Return 1 if `tag` is a paired HTML tag, 0 if not.
	let l:unpaired = ['DOCTYPE', 'doctype', 'br', 'hr', 'meta']

	if index(l:unpaired, a:tagname) >= 0 | retu 0 | el | retu 1 | en
endf


fun! s:WriteClosingTag(tagname)
	" Write the closing HTML tag.
	
	" Get the return position of the cursor that we want after writing the
	" closing HTML tag.
	let l:cursor_save_pos = getpos('.')

	" At ths point, the cursor is actually one column to the left of the
	" closing carrot ('>') on the opening HTML tag, so the position we want the
	" cursor to be on after writing the closing tag is two columns to the right
	" (i.e., on the open carrot ('<') of the closing HTML tag.)
	let l:cursor_save_pos[2] = l:cursor_save_pos[2]+2

	" Write the closing tag.
	exec "normal! A</" . a:tagname . ">"

	" Go to the return position and enter insert mode.
	call setpos('.', l:cursor_save_pos)
	startinsert
endf


fun! s:BetweenTags()
	" Return 1 if the cursor is sitting between two HTML tags, 0 if not.
	
	" At this point, we are checking to see if the cursor is resting between
	" two HTML tags. However, because we entered '<Esc>' before the function
	" call (i.e., exiting insert mode), the cursor was moved left one column.
	" So we actually need to check if the cursor is left of the '><' pattern
	" rather than between the '>' and '<'.
	if getline('.')[col('.')-1] == '>' && getline('.')[col('.')] == '<'
		retu 1
	el
		retu 0
	en
endf


fun! s:OnTabPress()
	" Binded to <Tab> in s:Init()

	" Check to see if we are inside of an opening tag
	if s:InsideOpenTag()
		if s:debug | echom "Inside of open tag." | en

		" Read the HTML tagname that is inside of the opening element
		let l:tagname = s:GetTag()
		if s:debug | echom "Tag is: '" . l:tagname . "'" | en

		if s:IsValidTag(l:tagname)
			if s:debug | echom "Tag is valid." | en

			if s:IsPairedTag(l:tagname)
				if s:debug | echom "Tag is paired." | en

				" Write the closing tag and move cursor between tags
				call s:WriteClosingTag(l:tagname)
			el
				if s:debug | echom "Tag is not paired." | en
				" Move cursor outside of the tag
				startinsert!
			en
		el
			if s:debug | echom "Tag is not valid." | en
			" todo - raise error is not a valid HTML tag
		en	
	el
		" Tab was pressed outside of an HTML element. Proceed as normal.
		if s:debug | echom "Not inside of open tag." | en
		exec "normal! la\<Tab>"
		startinsert
	en
endf


fun s:OnReturnPress()
	" Binded to <Cr> in s:Init()

	if s:BetweenTags()
		" If we are between two HTML tags, insert two carriage returns and
		" indent one layer in the blank space between the tags.
		if s:debug | echom "Cursor between tags." | en
		exec "normal! li\<Cr>\<Tab>\<Cr>\<Esc>k"
		startinsert!
	el
		" Return was pressed outside of an HTML element. Proceed as normal.
		if s:debug | echom "Cursor not between tags." | en
		exec "normal! a\<Cr>"
		startinsert
	en
endf


call s:Init()
