;--------------------------------------------------------------------------------
; SortArray - Sort array (from: https://autohotkey.com/boards/viewtopic.php?f=6&t=3790&p=20122)
SortArray(Arr)
{
    t:=Object()
	
    for k, v in Arr
        t[RegExReplace(v,"\s")] := v
	
    for k, v in t
        Arr[A_Index] := v
	
    return Arr
}

ReverseArray(arr)
{
	newArr := []
	
	for k, v in arr
		newArr.Insert(1, v)
	
	return newArr
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
