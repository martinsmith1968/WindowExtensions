;--------------------------------------------------------------------------------
; MinOf - Find the lower of 2 numbers
MinOf(a, b)
{
	if (a < b)
	{
		return a
	}
	else
	{
		return b
	}
}

;--------------------------------------------------------------------------------
; MaxOf - Find the higher of 2 numbers
MaxOf(a, b)
{
	if (a > b)
	{
		return a
	}
	else
	{
		return b
	}
}

;--------------------------------------------------------------------------------
; ContainsFlag - Does a value contain a bitwise value
ContainsFlag(value, bitwiseFlag)
{
	return (bitwiseFlag > 0) && (value & bitwiseFlag) > 0
}
