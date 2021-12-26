

fun! Init()

	" If '<' is pressed, autocomplete closing tag and move cursor within tag
	execute "au Filetype html inoremap <lt> <lt>><left"

	" If <Tab> is pressed, go to handling function
	execute "au Filetype html inoremap <Tab> :call <SID>Main()"

endf

fun! s:InsideTag()
	" Returns 1 if the cursor is between two carrots ('<>'), 0 if not.
endf


fun! s:IsText()
	" Returns 1 if text exists between two carrots ('<>'), 0 if not.

endf

fun! s:GetTag()
	" Returns the text within the carrots, only up to the first space,
	" ignoring any attributes that follow.

endf

fun! s:IsValidTag(tagname)
	" Return 1 if `tag` is a valid html tag, 0 if not.
	retu 1
endf

fun! s:IsPairedTag(tagname)
	" Return 1 if `tag` is a paired HTML tag, 0 if not.

endf

fun! s:Main()

	" If we are inside of a tag AND some text exists between the carrots
	if s:InsideTag() && s:IsText()

		" Read only text up to the first space, igoring the tag attributes
		l:tagname = s:GetTag()

		if s:IsValidTag(l:tag)

			if s:IsPairedTag(l:tag)

			el

			en
		el

		en
	el
		execute "normal! i<Tab>"

endf


call s:Init()
