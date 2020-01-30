#Include Lib\WindowFunctions.ahk

;--------------------------------------------------------------------------------
; WindowExtensionsDataFile - 
class WindowExtensionsDataFile extends DataFile
{
    __New(fullFileName)
    {
        base.__New(fullFileName)
    }
    
    BaseFileName
    {
        get
        {
            return StrSplit(this.FileNameNoExt, "-")[1]
        }
    }
    
    DesktopSizeDescription
    {
        get
        {
            return StrSplit(this.FileNameNoExt, "-")[2]
        }
    }
    
    DesktopSizeWidth
    {
        get
        {
            return StrSplit(this.DesktopSizeDescription, "x")[1]
        }
    }
    
    DesktopSizeHeight
    {
        get
        {
            return StrSplit(this.DesktopSizeDescription, "x")[2]
        }
    }
    
    FileTimestamp
    {
        get
        {
            return StrSplit(this.FileNameNoExt, "-")[3]
        }
    }
    
    FileCreatedTimestamp
    {
        get
        {
            fileName := this.FullFileName
            
            FileGetTime, timestamp, %fileName%, C
            
            return timestamp
        }
    }
    
    Timestamp
    {
        get
        {
            return this.FileTimestamp ? this.FileTimestamp : this.FileCreatedTimestamp
        }
    }
    
    BuildFileName()
    {
        desktopSizeDescription := this.DesktopSizeDescription
        if (!desktopSizeDescription)
        {
            currentDesktop := GetDesktopSize()
            desktopSizeDescription := currentDesktop.DimensionsText
        }
        
        fileNameOnly := JoinText("-", this.BaseFileName, desktopSizeDescription, this.Timestamp)
        
        fileName := CombinePaths(this.Directory, SetFileExtension(fileNameOnly, this.Extension))
        
        return fileName
    }
}
