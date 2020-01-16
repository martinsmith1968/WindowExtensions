#include Lib\IOUtils.ahk

;--------------------------------------------------------------------------------
; FileNameParser - Class to parse a file into its parts
class FileNameParser
{
_FullFileName :=

    __New(fullFileName)
    {
        this.FullFileName := fullFileName
    }
    
    FullFileName
    {
        get
        {
            return this._FullFileName
        }
        set
        {
            this._FullFileName := value
        }
    }
    
    Drive
    {
        get
        {
            fileName := this.FullFileName
            SplitPath, fileName,,,,, drive
            
            return drive
        }
    }
    
    Directory
    {
        get
        {
            fileName := this.FullFileName
            SplitPath, fileName,, directory
            
            return directory
        }
    }
    
    FileName
    {
        get
        {
            fileName := this.FullFileName
            SplitPath, fileName, fileName
            
            return fileName
        }
    }
    
    Extension
    {
        get
        {
            fileName := this.FullFileName
            SplitPath, fileName,,, extension
            
            return extension
        }
    }
    
    FileNameNoExt
    {
        get
        {
            fileName := this.FullFileName
            SplitPath, fileName,,,, fileNameNoExt
            
            return fileNameNoExt
        }
    }
}

;--------------------------------------------------------------------------------
; DataFile - Class to represent a data file with a well formed name
class DataFile extends FileNameParser
{
	__New(fullFileName)
	{
        base.__New(fullFileName)
    }
    
    Content
    {
        get
        {
            return FileReadContent(this.FullFileName)
        }
    }
    
    ContentLines
    {
        get
        {
            return FileReadContentLines(this.FullFileName)
        }
    }
    
    LineCount
    {
        get
        {
            return this.ContentLines.length()
        }
    }
    
    CRC32
    {
        get
        {
            hash := CRC32(this.Content)
            
            return hash
        }
    }
    
    Adler32
    {
        get
        {
            hash := Adler32(this.Content)
            
            return hash
        }
    }
    
    SHA1
    {
        get
        {
            hash := SHA1(this.Content)
            
            return hash
        }
    }
    
    MD5
    {
        get
        {
            hash := MD5(this.Content)
            
            return hash
        }
    }
}
