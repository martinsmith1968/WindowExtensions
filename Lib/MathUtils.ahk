
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

ContainsFlag(value, bitwiseFlag)
{
	return (bitwiseFlag > 0) && (value & bitwiseFlag) > 0
}
