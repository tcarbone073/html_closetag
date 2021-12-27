
fun! Init()

	" If '<' is pressed, autocomplete closing tag and move cursor within tag
	exec "au Filetype html inoremap <lt> <lt>><left"

	" If <Tab> is pressed, go to handling function
	exec "au Filetype html inoremap <Tab> <Esc>:call <SID>OnTabPress()"

	" If <Return> is prssed, go to handing function
	exec "au filetype html inoremap <Return> <Esc>:call <SID>OnReturnPress()"	

endf


fun! s:InsideOpenTag()
	" Returns 1 if the cursor is between two carrots ('<>'), 0 if not.
	if getline('.')[col('.')] == '>'
		retu 1
	el
		retu 0
	end
endf


fun! s:GetTag()
	" Returns the text within the opening HTML tag, only up to the first space,
	" ignoring any attributes that follow.
	let l:text = matchstr(getline(search("<.>")), "<.>")
	retu split(l:text)[0]
endf


fun! s:IsValidTag(tagname)
	" Return 1 if `tag` is a valid html tag, 0 if not.	
	retu 1
endf


fun! s:IsPairedTag(tagname)
	" Return 1 if `tag` is a paired HTML tag, 0 if not.
	let l:unpaired = ['DOCTYPE', 'doctype', 'br', 'hr', 'meta']

	if a:tagname in l:unpaired
		retu 0
	el
		retu 1
	en
endf


fun! s:WriteClosingTag(tagname)
	" Write the closing HTML tag at the end of the line
	exec "normal! a</" . a:tagname . ">"
endf


fun! s:OnTabPress()

	" Check to see if we are inside of an opening tag
	if s:InsideOpenTag()

		" Read the HTML tagname that is inside of the opening element
		l:tagname = s:GetTag()

		if s:IsValidTag(l:tagname)

			if s:IsPairedTag(l:tagname)

				" Write the closing tag and move cursor between tags
				s:WriteClosingTag(l:tagname)
			el
				" Move cursor outside of the tag
				exec "normal! a"
			en
		el
			" todo - raise error is not a valid HTML tag
		en	
	en
		" Tab was pressed outside of an HTML element. Proceed as normal.
		exec "normal! i<Tab>"
endf


fun OnReturnPress()
	if s:BetweenTags()
		" Enter two newlines and indent between tags

	en
endf


call s:Init()
