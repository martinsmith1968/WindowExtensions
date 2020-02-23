StringRepeat(string, times)
{
    Loop, %times%
        output .= string

    Return output
}

EnsureStartsWith(text, prefix)
{
    prefixLength := StrLen(prefix)

    if (prefixLength > 0)
    {
        If (SubStr(text, 1, prefixLength) != prefix)
            text := prefix . text
    }
    
    return text
}

EnsureEndsWith(text, suffix)
{
    suffixLength := StrLen(suffix)

    if (suffixLength > 0)
    {
        If (SubStr(text, 1 - suffixLength) != suffix)
            text := text . suffix
    }
    
    return text
}

RemoveStartsWith(text, prefix)
{
    prefixLength := StrLen(prefix)

    if (prefixLength > 0)
    {
        while(SubStr(text, 1, prefixLength) = prefix)
            text := SubStr(text, prefixLength + 1)
    }
    
    return text
}

RemoveEndsWith(text, suffix)
{
    suffixLength := StrLen(suffix)

    if (suffixLength > 0)
    {
        while(SubStr(text, 1 - suffixLength) = suffix)
            text := SubStr(text, 1, StrLen(text) - suffixLength)
    }
    
    return text
}

ToUpper(text)
{
    StringUpper, result, text
    
    return result
}

ToLower(text)
{
    StringLower, result, text
    
    return result
}

JoinText(sep, params*)
{
    for index, param in params
        str .= param . sep
    
    return SubStr(str, 1, -StrLen(sep))
}

JoinItems(sep, array)
{
    for index, param in array
        str .= param . sep
    
    return SubStr(str, 1, -StrLen(sep))
}

; Tests

;xx := "This is made of glass"

;yy := RemoveEndsWith(xx, "s")
;zz := EnsureEndsWith(xx, "s")
;ww := EnsureEndsWith(xx, "x")

;yy := EnsureStartsWith(xx, ".")
;yy := RemoveStartsWith(xx, "T")
