StringRepeat(string, times)
{
	Loop, %times%
		output .= string

	Return output
}

EnsureEndsWith(string, suffix)
{
	suffixLength := suffix.Length

	currentSuffix := SubStr(string, -1 * suffixLength)

	If (currentSuffix != suffix)
		string := string . suffix
	
	return string
}
