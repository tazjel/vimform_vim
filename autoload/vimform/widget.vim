" widget.vim
" @Author:      Thomas Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2010-04-14.
" @Last Change: 2010-04-24.
" @Revision:    0.0.43

let s:save_cpo = &cpo
set cpo&vim


let s:prototype = {
            \ 'modifiable': 0,
            \ 'default_value': 0,
            \ 'complete': '',
            \ }


function! s:prototype.FormatLabel(form) dict "{{{3
    return self.name
endf


function! s:prototype.Format(form, value) dict "{{{3
    return a:value
endf


function! s:prototype.GetFieldValue(form, value) dict "{{{3
    return a:value
endf


function! s:prototype.SelectField(form, to_insertmode) dict "{{{3
    " TLogVAR a:to_insertmode
    if self.modifiable && a:to_insertmode
        call vimform#Insertmode()
    endif
endf


function! s:prototype.GetValidate(form) dict "{{{3
    return get(self, 'validate', '')
endf


function! s:prototype.SetCursorMoved(form, insertmode, lnum) dict "{{{3
    " TLogVAR a:insertmode, a:lnum, col('.'), a:form.indent
    if col('.') <= a:form.indent
        call cursor(a:lnum, a:form.indent + 1)
    endif
endf


function! s:prototype.GetPumKey(form, key) dict "{{{3
    return a:key
endf


function! s:prototype.GetSpecialInsertKey(form, key) dict "{{{3
    return a:key
endf


function! s:prototype.GetSpecialKey(form, name, key) dict "{{{3
    return get(a:form.mapargs, a:key, a:key)
endf


function! s:prototype.GetKey(form, key) dict "{{{3
    let key = a:key
    if a:key =~ '^[ai]$'
        let ccol = col('.')
        " TLogVAR ccol, ecol, a:form.indent
        if a:key == 'a' && ccol < a:form.indent
            let key = ''
        elseif a:key == 'i' && ccol <= a:form.indent
            let key = ''
        elseif ccol >= a:form.indent && self.modifiable
            call a:form.SetModifiable(1)
        endif
    endif
    return key
endf


function! s:prototype.Key_dd(form) dict "{{{3
    let key  = 'dd'
    let lnum = line('.')
    let line = getline(lnum)
    let steps = 1
    let srx = a:form.GetSpecialRx()
    if line =~ a:form.GetFieldsRx()
        " if lnum < line('$') && getline(lnum + 1) =~ a:form.GetIndentRx()
        if lnum < line('$') && getline(lnum + 1) !~ srx
            let key = a:form.indent .'|d$J'
            let steps += 2
        elseif empty(strpart(line, a:form.indent))
            let key = ''
        else
            let key = a:form.indent .'|d$'
            let steps += 1
        endif
    elseif lnum < line('$') && getline(lnum + 1) =~ srx
        call a:form.IgnoreCursorMoved(1)
        let key .= 'k'
    endif
    if !empty(key) && self.modifiable
        call a:form.SetModifiable(steps)
    endif
    return key
endf


function! s:GetSelectionRange() "{{{3
    let l1 = line("v")
    let l2 = line("'.")
    return [l1, l2]
endf


function! s:prototype.Key_BS(form) dict "{{{3
    let min = a:form.indent + 1
    " (mode() == 'n')
    if col('.') <= min || !self.modifiable
        let key = ''
    elseif mode() =~? '[vs]$'
        let [l1, l2] = s:GetSelectionRange()
        let n1 = a:form.GetCurrentFieldName([0, l1, 0, 0])
        let n2 = a:form.GetCurrentFieldName([0, l2, 0, 0])
        " TLogVAR l1, n1, l2, n2
        if n1 == n2
            let key = "\<bs>"
        else
            let key = ''
        endif
    else
        let key = mode() == 'n' ? 'X' : "\<bs>"
        call a:form.SetModifiable(1)
    endif
    return key
endf


function! s:prototype.Key_DEL(form) dict "{{{3
    let lnum = line('.')
    let frx  = a:form.GetFieldsRx()
    if !self.modifiable || col('.') >= col('$') && (lnum == line('$') || getline(lnum + 1) =~ frx)
        let key = ''
    elseif mode() =~? '[vs]$'
        let [l1, l2] = s:GetSelectionRange()
        let n1 = a:form.GetCurrentFieldName([0, l1, 0, 0])
        let n2 = a:form.GetCurrentFieldName([0, l2, 0, 0])
        " TLogVAR l1, n1, l2, n2
        if n1 == n2
            let key = "\<del>"
        else
            let key = ''
        endif
    else
        let key = "\<del>"
        call a:form.SetModifiable(1)
    endif
    return key
endf


function! vimform#widget#New() "{{{3
    return deepcopy(s:prototype)
endf


let &cpo = s:save_cpo
unlet s:save_cpo
