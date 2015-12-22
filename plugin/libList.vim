" File: libList.vim
" Last Change: 2001 Dec 10
" Maintainer: Gontran BAERTS <gbcreation@free.fr>
" Version: 0.1
"
" Please don't hesitate to correct my english :)
" Send corrections to <gbcreation@free.fr>
"
"-----------------------------------------------------------------------------
" Description: libList.vim is a set of functions to work with lists or one
" level arrays.
"
"-----------------------------------------------------------------------------
" To Enable: Normally, this file will reside in your plugins directory and be
" automatically sourced.
"
"-----------------------------------------------------------------------------
" Usage: Lists are strings variable with values separated by g:listSep
" character (comma" by default). You may redefine g:listSep variable as you
" wish.
"
" Here are available functions :
"
" - AddListItem( array, newItem, index ) :
"		Add item "newItem" to array "array" at "index" position
" - GetListItem( array, index ) :
"		Return item at "index" position in array "array"
" - GetListMatchItem( array, pattern ) :
"		Return item matching "pattern" in array "array"
" - GetListCount( array ) :
"		Return the number of items in array "array"
" - RemoveListItem( array, index ) :
"		Remove item at "index" position from array "array"
" - ReplaceListItem( array, index, item ) :
"		Remove item at "index" position by "item" in array "array"
" - ExchangeListItems( array, item1Index, item2Index ) :
" 		Exchange item "item1Index" with item "item2Index" in array "array"
" - QuickSortList( array, beg, end ) :
" 		Return array "array" with items between "beg" and "end" sorted
"
" Example:
" let mylist=""
" echo GetListCount( mylist ) " --> 0
" let mylist = AddListItem( mylist, "One", 0 ) " mylist == "One"
" let mylist = AddListItem( mylist, "Three", 1 ) " mylist == "One,Three"
" let mylist = AddListItem( mylist, "Two", 1 ) " mylist == "One,Two,Three"
" echo GetListCount( mylist ) " --> 3
" echo GetListItem( mylist, 2 ) " --> Three
" echo GetListMatchItem( mylist, "w" ) " --> two
" echo GetListMatchItem( mylist, "e" ) " --> One
" let mylist = RemoveListItem( mylist, 2 ) " mylist == "One,Two"
" echo GetListCount( mylist ) " --> 2
" let mylist = ReplaceListItem( mylist, 0, "Three" ) " mylist == "Three,Two"
" let mylist = ExchangeListItems( mylist, 0, 1 ) " mylist == "Two,Three"
" let mylist = AddListItem( mylist, "One", 0 ) " mylist == "One,Two,Three"
" let mylist = QuickSortList( mylist, 0, GetListCount(mylist)-1 )
" " mylist == "One,Three,Two"
"
"-----------------------------------------------------------------------------
" Updates:
" in version 0.1
" - First version

" Has this already been loaded ?
if exists("loaded_libList")
       finish
endif
let loaded_libList=1

"**
" Separator:
" You may change the separator character et any time.
"**
let g:listSep = ","

"**
"AddListItem:
"	Add new item at given position.
"	First item index is 0 (zero).
"Parameters:
" - array : Array/List (string of values) which receives the new item.
" - newItem : String containing the item value to add.
" - index : Integer indicating the position at which the new item is added.
" 			It must be greater than or equals to 0 (zero).
"Return:
"String containing array values, including newItem.
"**
function AddListItem( array, newItem, index )
	return latexsuite#liblist#AddListItem(a:array, a:newItem, a:index)
endfunction

"**
"GetListItem:
"	Get item at given position.
"Parameters:
" - array : Array/List (string of values).
" - index : Integer indicating the position of item to return.
" 			It must be greater than or equals to 0 (zero).
"Return:
"String representing the item.
"**
function GetListItem( array, index )
	return latexsuite#liblist#GetListItem(a:array, a:index)
endfunction

"**
"GetListMatchItem:
"	Get the first item matching given pattern.
"Parameters:
" - array : Array/List (string of values).
" - pattern : Regular expression to match with items.
"			  Avoid to use ^, $ and listSep characters in pattern, unless you
"			  know what you do.
"Return:
"String representing the first item that matches the pattern.
"**
function GetListMatchItem( array, pattern )
	return latexsuite#liblist#GetListMatchItem(a:array, a:pattern)
endfunction

"**
"ReplaceListItem:
"	Replace item at given position by a new one.
"Parameters:
" - array : Array/List (string of values).
" - index : Integer indicating the position of item to replace.
" 			It must be greater than or equals to 0 (zero).
" - item : String containing the new value of the replaced item.
"Return:
"String containing array values.
"**
function ReplaceListItem( array, index, item )
	return latexsuite#liblist#ReplaceListItem(a:array, a:index, a:item)
endfunction

"**
"RemoveListItem:
"	Remove item at given position.
"Parameters:
" - array : Array/List (string of values) from which remove an item.
" - index : Integer indicating the position of item to remove.
" 			It must be greater than or equals to 0 (zero).
"Return:
"String containing array values, except the removed one.
"**
function RemoveListItem( array, index )
	return latexsuite#liblist#RemoveListItem(a:array, a:index)
endfunction

"**
"ExchangeListItems:
"	Exchange item at position item1Index with item at position item2Index.
"Parameters:
" - array : Array/List (string of values).
" - item1index : Integer indicating the position of the first item to exchange.
" 				 It must be greater than or equals to 0 (zero).
" - item2index : Integer indicating the position of the second item to
"				 exchange. It must be greater than or equals to 0 (zero).
"Return:
"String containing array values.
"**
function ExchangeListItems( array, item1Index, item2Index )
	return latexsuite#liblist#ExchangeListItems(a:array, a:item1Index, a:item2Index)
endfunction

"**
"GetListCount:
"	Number of items in array.
"Parameters:
" - array : Array/List (string of values).
"Return:
"Integer representing the number of items in array.
"Index of last item is GetListCount(array)-1.
"**
function GetListCount( array )
	return latexsuite#liblist#GetListCount(a:array)
endfunction

"**
"QuickSortList:
"	Sort array.
"Parameters:
" - array : Array/List (string of values).
" - beg : Min index of the range of items to sort.
" - end : Max index of the range of items to sort.
"Return:
"String containing array values with indicated range of items sorted.
"**
function QuickSortList( array, beg, end )
	return latexsuite#liblist#QuickSortList(a:array, a:beg, a:end)
endfunction


