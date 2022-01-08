" Global flag to toggle debug mode (i.e., echoing variables)
let s:debug = 0

fun! s:Init()

	" If '<' is pressed, autocomplete closing tag and move cursor within tag	
	au Filetype html inoremap <silent> <lt> <lt><Esc>:call <SID>OnLessThanPress()<Cr>

	" If <Tab> is pressed, go to handling function
	au Filetype html inoremap <silent> <Tab> <Esc>:call <SID>OnTabPress()<Cr>

	" If <Return> is prssed, go to handing function
	au filetype html inoremap <silent> <Cr> <Esc>:call <SID>OnReturnPress()<Cr>

endf

" These checks run when <Tab> is pressed ---------------------------------- {{{

" For all of these checks, be mindful that before calling main handling
" function when a <Tab> is pressed, <Esc> was entered. Unless the cursor is at
" column 1, the cursor will move left one column. So, some of the logic here is
" checking if a character exists some amount of columns to the right of the
" cursor.
"
" All of these functions return with the cursor in the same spot as when they
" were entered to prevent bugs down the line.

fun! s:AtEndOfOpenTag()
	" Returns 1 if the cursor is at the end of an opening HTML tag, 0 if not.
	
	if getline('.')[col('.')] == '>' | retu 1 | el | retu 0 | en
endf


fun! s:AtEndQuote()
	" Returns 1 if cursor is at a closing single or double quote, 0 if not.
	"
	if getline('.')[col('.')] == '''' || getline('.')[col('.')] == '"'
		retu 1
	el
		retu 0
	en
endf


fun! s:AtEndOfInnerHTML()
	" Return 1 if cursor is at the end of any inner HTML, 0 if not.
	"
	" Ex: Returns 1 for the following situations:
	" 	<sometag>foo|</sometag>
	" 	-OR-
	" 	<sometag>
	" 		foo|  <-- only returns 1 if cursor is at end of line
	" 	</sometag>
	
	let l:thisline = getline('.')
	let l:nextline = getline(line('.')+1)
	
	" Check if next two chracters are '</'
	if strpart(l:thisline, col('.'), 2) == '</'
		retu 1

	" Check if first two non-blank characters on next line are '</'
	elseif col('.') == col('$')-1 
		if strpart(l:nextline, match(l:nextline, '\S'), 2) == '</'
			retu 1
		el
			retu 0
		en
	el
		retu 0
	en
endf
" }}}


fun! s:WriteGreaterThan()
	" Write a 'greater than' ('>') character immediately after the opening
	" 'less than' ('<') character, move the cursor left one column, and enter
	" insert mode.
	
	exec "normal! a>"
	startinsert
endf


fun! s:GetTag()
	" Returns the text within the opening HTML tag, only up to the first space,
	" ignoring any attributes that follow.
	"
	" Ex:	If the line is '<head>', returns 'head'.
	" 		If the line is '<a href="someurl"', returns 'a'
	
	" Get the entire current line.
	let l:line = getline('.')
	if s:debug | echom "  Line is: '" . l:line . "'" | en

	" Get columns of the opening and closing carrots '<>' of the opening tag
	let [@_, l:start] = searchpos('<', 'bn')
	let [@_, l:end] = searchpos('>', 'n')	
	if s:debug | echom "  '<','>' are at cols: " . l:start . "," . l:end | en

	" Get the string that is between the carrots ('<>'). Note here that
	" `strpart` is indexing `l:line` on a 0-based index. The value of `s:start`
	" and `l:end` are column values (which start at 1), corrsponding to the
	" column positions of '<' and '>'. This is convenient for `s:start` because
	" we want to start parsing one column right of '<'.
	let l:element = strpart(l:line, l:start, l:end - l:start - 1)
	if s:debug | echom "  Text between '<>' is: '" . l:element . "'" | en

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
	exec "normal! la</" . a:tagname . ">"

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


fun! s:SnapOutOfQuote()
	" Move the cursor one column right and enter insert mode.
	
	if col(".") == col("$")-2
		if s:debug | echom "  At end of line" | en
		startinsert!
	el
		if s:debug | echom "  Not at end of line" | en
		exec "normal! lla"
		startinsert
	en
endf


fun! s:SnapOutOfInnerHTML()
	" Move the cursor one column right of the nearest closing HTML tag and
	" enter insert mode
	
	let l:linenum = search('>', 'ze')
	if col('.') == col('$')-1
		startinsert!
	el
		exec "normal! la"
		startinsert
	en
endf


fun! s:InsertRegularTab()
	" Insert regular tab and enter insert mode.
	
	if col('.') == col('$')
		exec "normal! i\<Tab>"
		startinsert!

	elseif col(".") == col("$")-1
		exec "normal! a\<Tab>"
		startinsert!

	elseif getline('.')[col('.')-1] == "\t"
		exec "normal! a\<Tab>\<Right>"
		startinsert

	elseif col('.') == 1
		exec "normal! i\<Tab>\<Right>"
		startinsert

	el
		exec "normal! a\<Tab>\<Right>"
		startinsert
	en
endf


fun! s:OnLessThanPress()
	if s:debug | echom "<lt> Pressed..." | en

	" Write the closing 'greater than' ('>') character.
	call s:WriteGreaterThan()

endf


fun! s:OnTabPress()
	if s:debug | echom "<Tab> Pressed..." | en

	" All of these checks exit with the cursor in the same position as when
	" they were entered.

	" Check to see if we are ready to write the corresponding closing HTML tag
	if s:AtEndOfOpenTag()
		if s:debug | echom " Case 1: At end of opening HTML tag." | en

		" Read the HTML tagname that is inside of the opening element
		let l:tagname = s:GetTag()
		if s:debug | echom "  Tag is: '" . l:tagname . "'" | en

		if s:IsValidTag(l:tagname)
			if s:debug | echom "  Tag is valid." | en

			if s:IsPairedTag(l:tagname)
				if s:debug | echom "  Tag is paired." | en

				" Write the closing tag and move cursor between tags
				call s:WriteClosingTag(l:tagname)
			el
				if s:debug | echom "  Tag is not paired." | en
				" Move cursor outside of the tag
				startinsert!
			en
		el
			if s:debug | echom "  Tag is not valid." | en
			" todo - raise error is not a valid HTML tag
		en	


	elseif s:AtEndQuote()

		" The cursor is resting on an ending single or double quote.
		if s:debug | echom " Case 2: At endquote." | en
		call s:SnapOutOfQuote()

	elseif s:AtEndOfInnerHTML()

		" The cursor is resting at the end of any inner HTML.
		if s:debug | echom " Case 3: At end of inner HTML" | en
		call s:SnapOutOfInnerHTML()

	el
		
		" The cursor is not at the end of an opening HTML tag, not at en
		" endquote, and not at the end of any inner HTML.
		if s:debug | echom " Case 4: Regular tab." | en
		call s:InsertRegularTab()
	en
endf


fun s:OnReturnPress()
	if s:debug | echom "<Cr> Pressed..." | en

	if s:BetweenTags()
		" If we are between two HTML tags, insert two carriage returns and
		" indent one layer in the blank space between the tags.
		if s:debug | echom " Case 1: Cursor between HTML tags." | en
		exec "normal! li\<Cr>\<Tab>\<Cr>\<Esc>k"
		startinsert!
	el
		" Return was pressed outside of an HTML element. Proceed as normal.
		if s:debug | echom " Case 2: Regular carriage return." | en
		exec "normal! a\<Cr>"
		startinsert
	en
endf


call s:Init()
