;--------------------------------------------------------------------------------
; AutoSort - Sort array (from: https://autohotkey.com/boards/viewtopic.php?f=6&t=3790&p=20122)
AutoSort(Arr)
{
    t:=Object()
	
    for k, v in Arr
        t[RegExReplace(v,"\s")] := v
	
    for k, v in t
        Arr[A_Index] := v
	
    return Arr
}

;--------------------------------------------------------------------------------
; IndexOf - Find the index of an array item
IndexOf(array, item)
{
    for index, param in array
	{
		if (param = item)
			return index
	}
	
    return 0
}
