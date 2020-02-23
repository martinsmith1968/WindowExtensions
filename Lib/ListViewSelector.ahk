#Include Lib\ArrayUtils.ahk
#Include Lib\StringUtils.ahk
#Include Lib\MathUtils.ahk

G_CurrentListViewSelector := ""

class ListViewSelector
{
Title := "Select..."
ColumnNames := []
ColumnOptions := []
Items := []
SelectedIndex := 0
MinRowCountSize := 5
MaxRowCountSize := 20
ListViewWidth := 400
OnSuccess := ""

    __New()
    {
        this.Title := "Select..."
        this.ColumnNames := []
        this.ColumnOptions := []
        this.Items := []
        this.SelectedIndex := 0
        this.MinRowCountSize := 5
        this.MaxRowCountSize := 20
        this.ListViewWidth := 400
        this.OnSuccess := ""
    }
    
    ShowDialog()
    {
        global G_CurrentListViewSelector
        
        G_CurrentListViewSelector := this
        
        this.BuildGui()

        if (this.SelectedIndex)
        {
            LV_Modify(this.SelectedIndex, "Select")
        }
        
        this.PopulateItems()

        this.SetupColumns()

        Gui, LvwSelector:Show
    }

    BuildGui()
    {
        title := this.Title
        columnNameText := JoinItems("|", this.ColumnNames)
        rowCount := MinOf(MaxOf(this.Items.length(), this.MinRowCountSize), this.MaxRowCountSize)
        
        buttonWidth := 80
        buttonLeft := this.ListViewWidth - (buttonWidth * 2)
        
        listViewWidth := this.ListViewWidth
        
        Gui, LvwSelector:New, -SysMenu, %title%
        Gui, LvwSelector:Add, ListView, r%rowCount% w%listViewWidth% gLvwSelectorListView, %columnNameText%
        
        Gui, LvwSelector:Add, Button, Section default x%buttonLeft% w80 gLvwSelectorGuiButtonOK, OK
        Gui, LvwSelector:Add, Button, ys x+10 w80, Cancel
    }
    
    PopulateItems()
    {
        LV_Delete()
        
        for index, item in this.Items
        {
            LV_Add("", item*)
        }
    }
    
    SetupColumns()
    {
        for index, item in this.ColumnOptions
        {
            LV_ModifyCol(index, item)
        }
    }
}

;--------------------------------------------------------------------------------
; DestroyConfigGui - Destroy the Config Gui
DestroyLvwSelectorGui()
{
    Gui, LvwSelector:Destroy
}

LvwSelectorListView()
{
    if (A_GuiEvent = "DoubleClick")
    {
        LV_Modify(A_EventInfo, "Select")
        LvwSelectorGuiButtonOK()
    }
}

LvwSelectorButtonCancel()
{
    DestroyLvwSelectorGui()
}

LvwSelectorGuiEscape()
{
    LvwSelectorButtonCancel()
}

LvwSelectorGuiButtonOK()
{
    global G_CurrentListViewSelector
        
    G_CurrentListViewSelector.SelectedIndex := LV_GetNext()
    if (!(G_CurrentListViewSelector.SelectedIndex))
        return
        
    Gui, LvwSelector:Submit
    
    DestroyLvwSelectorGui()
    
    funcName := G_CurrentListViewSelector.OnSuccess
    if (funcName)
    {
        %funcName%(G_CurrentListViewSelector)
    }
}
