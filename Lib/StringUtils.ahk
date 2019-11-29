StringRepeat(string, times)
{
	Loop, %times%
		output .= string

	Return output
}

EnsureEndsWith(text, suffix)
{
	suffixLength := suffix.Length

	currentSuffix := SubStr(text, -1 * suffixLength)

	If (currentSuffix != suffix)
		text := text . suffix
	
	return text
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
