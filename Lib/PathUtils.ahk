#include Lib\StringUtils.ahk

CombinePaths(path1, path2)
{
    return EnsureEndsWith(path1, "\") . path2
}

CombinePathA(paths*)
{
    newPath := 

    Loop, %path%
    {
        if (newPath = "")
        {
            newPath := path
        }
        else
        {
            newPath := EnsureEndsWith(newPath, "\") . path
        }
    }

    return newPath
}

DirectoryExists(path)
{
    return Instr(FileExist(path), "H")
}
