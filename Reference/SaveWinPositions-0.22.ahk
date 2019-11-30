; SaveWinPositions
; Version v0.22

; Obtiene el nombre, ID, posición y tamaño (x,y,w,h) de todas las ventanas.
; Incluídas las minimizadas.
; Crea un fichero "WinPos.txt" en %TEMP% conteniendo sus posiciones.

; Comprobamos que el programa no se ha activado por un disparo en falso (apagado/encendido casi simultáneo) del salvapantallas:
FileGetTime, FechaOriginal, %TEMP%\WinPos.txt
TiempoTranscurrido := A_Now-FechaOriginal
If FechaOriginal =
    TiempoTranscurrido := 10
If TiempoTranscurrido<=5
{   ; Se grabaron datos de posiciones de ventanas hace 5 segundos o menos.
    FileAppend, % "* " . A_YYYY . "-" . A_MM . "-" . A_DD . " " . A_Hour . ":" . A_Min . ":" . A_Sec . " --> " . "SaveWinPositions:-> Se grabaron datos de posiciones de ventanas hace " . TiempoTranscurrido . " segundos. Disparo en falso del salvapantallas. No se almacenarán posiciones de ventanas. Saliendo de SaveWinPositions. `n", %TEMP%\WinPositions-Log.txt
    TrayTip, SaveWinPositions, Se grabaron datos de posiciones de ventanas hace %TiempoTranscurrido% segundos. Disparo en falso del salvapantallas. Abortando., ,1
    sleep 10000
    Exit        ; Disparo en falso del salvapantallas. Cancelando la ejecución del programa.
}

NumParametros = %0%
Parametro1 = %1%
NumeroDePantallasEsperado:=1    ; El sistema dispone de este número de pantallas en total. No se deben mover ventanas ni grabar sus posiciones si no están encendidas todas.
    ;Nótese que este será el valor por defecto de no ser especificado mediante parámetro en la línea de comandos ni existir %A_WorkingDir%\screens.cfg.
If ( NumParametros<1 )  ; Comprobamos el número de parámetros.
{       ; Si no hay parámetros, capturamos el número de pantallas del fichero de configuración (por defecto en el directorio de ejecución del programa), si existe:
    IfExist, screens.cfg    ; Si existe el fichero de configuración...
    {   ; ... leemos de él el número de pantallas esperado.
        FileReadLine,NumeroDePantallasEsperado,%A_WorkingDir%\screens.cfg,1
        FileAppend, % "* " . A_YYYY . "-" . A_MM . "-" . A_DD . " " . A_Hour . ":" . A_Min . ":" . A_Sec . " --> " . "SaveWinPositions:-> No se introdujeron parámetros, se utilizará el extraído del fichero de configuración.`n", %TEMP%\WinPositions-Log.txt
    } else
    {   ; No existe el fichero de configuración: informamos en el log.
        FileAppend, % "* " . A_YYYY . "-" . A_MM . "-" . A_DD . " " . A_Hour . ":" . A_Min . ":" . A_Sec . " --> " . "SaveWinPositions:-> No existe el fichero de configuración.`n", %TEMP%\WinPositions-Log.txt
    }

} else
{   ; Si hay parámetros...
    If ( Parametro1 = 0 )   ; si el parámetro es un 0...
    {   ; Ignorar número de monitores
    IgnoreNumPantallas = 1
    FileAppend, % "* " . A_YYYY . "-" . A_MM . "-" . A_DD . " " . A_Hour . ":" . A_Min . ":" . A_Sec . " --> " . "SaveWinPositions:-> Ignorando número de monitores: se ejecutará el programa sin esperarlos.`n", %TEMP%\WinPositions-Log.txt
    } else
    {   ; si el parámetro es distinto de 0...
        ; ... el parámetro contiene el número de pantallas esperado:
        NumeroDePantallasEsperado = %1%
    }
}
If ( Parametro1 != 0 )  ; a menos que se ignore el número de monitores...
{   ; ... añadimos una entrada al log con el número de pantallas necesarias.
    FileAppend, % "* " . A_YYYY . "-" . A_MM . "-" . A_DD . " " . A_Hour . ":" . A_Min . ":" . A_Sec . " --> " . "SaveWinPositions:-> Numero de monitores esperado: " . NumeroDePantallasEsperado ".`n", %TEMP%\WinPositions-Log.txt
}
; Comprobamos que estén todos los monitores conectados:
SysGet, m, MonitorCount
If ( not IgnoreNumPantallas and m < NumeroDePantallasEsperado )
{
    FileAppend, % "* " . A_YYYY . "-" . A_MM . "-" . A_DD . " " . A_Hour . ":" . A_Min . ":" . A_Sec . " --> " . "SaveWinPositions:-> Número de pantallas actual: " . m . "; se esperaba al menos " . NumeroDePantallasEsperado . ". Saliendo de SaveWinPositions. `n", %TEMP%\WinPositions-Log.txt
    TrayTip, SaveWinPositions, Número de pantallas actual: %m% (se esperaba al menos %NumeroDePantallasEsperado%). Abortando., ,2
    sleep 10000
    Exit        ; No están todas las pantallas. Cancelamos la ejecución del programa.
}

; Comprobamos si el salvapantallas está activo:
SalvaPantallas := WinExist("Protector de pantalla")

FileAppend, % "* " . A_YYYY . "-" . A_MM . "-" . A_DD . " " . A_Hour . ":" . A_Min . ":" . A_Sec . " --> " . "SaveWinPositions:-> Grabando posiciones de las ventanas del Escritorio `n", %TEMP%\WinPositions-Log.txt
FileDelete, %TEMP%\WindowsPositions.txt
WinGet windows, List
Loop %windows%
{
    ContainsSpecialCharacter:=0
    id := windows%A_Index%
    WinGetTitle wt, ahk_id %id%
    WinGet, WinStatus, MinMax, ahk_id %id%
    if (WinStatus=-1)
    {   ; Esta ventana está minimizada.
        WinGetNormalPos(id, x, y, w, h)
        If (x+y+w+h=0)
        {   ; Todas sus coordenadas parecen valer 0. Necesitamos restaurarla para capturarlas corréctamente.
            FileAppend, % "* " . A_YYYY . "-" . A_MM . "-" . A_DD . " " . A_Hour . ":" . A_Min . ":" . A_Sec . " --> " . "SaveWinPositions:-> Posible problema en ventana : " . wt . ". Es necesario restaurarla para detectar sus coordenadas."
            WinRestore, ahk_id %ID%
            WinGetPos, x,y,w,h,ahk_id %ID%
            WinMinimize, ahk_id %ID%
            WindowRestored:=1
        } 
    } else
    {   ; Esta ventana no está minimizada. Recurrimos a captura normal de coordenadas.
        WinGetPos,x,y,w,h,ahk_id %id%
    }
    If (wt and wt!="Inicio")        ; Ignore Windos Title null and "Inicio".
    {   ; Añadir al fichero de datos: Coordenadas, dimensiones y título de la ventana.
        r .= ID . "," . x . "," . y . "," . w . "," . h . "," . wt . "`n"
    }
    FileAppend , %r%, %TEMP%\WindowsPositions.txt
}

; Ordenamos por ID de ventana el fichero resultante:
FileRead, OutputVar, %TEMP%\WindowsPositions.txt
Sort, OutputVar, u  ; Se producen duplicados de líneas, no sabemos aún porqué. :-P

; Duplicamos el fichero anteriormente existente de las posiciones de las ventanas, por si las moscas.
FileDelete, %TEMP%\WinPos-.txt
FileCopy, %TEMP%\WinPos--.txt, %TEMP%\WinPos---.txt
FileCopy, %TEMP%\WinPos-.txt, %TEMP%\WinPos--.txt
FileCopy, %TEMP%\WinPos.txt, %TEMP%\WinPos-.txt
FileDelete, %TEMP%\WinPos.txt
FileAppend, %OutputVar%,%TEMP%\WinPos.txt

If (SalvaPantallas and WindowRestored)
{   ; El programa necesitó desactivar el salvapantallas. Procedemos a reactivarlo:
    FileAppend, % "* " . A_YYYY . "-" . A_MM . "-" . A_DD . " " . A_Hour . ":" . A_Min . ":" . A_Sec . " --> " . "SaveWinPositions:-> Estaba en funcionamiento el salvapantallas y hubo de ser desactivado. Reactivándolo..."
    ; Método alternativo para activación del salvapantallas (requiere NirSoft NirCmd en el path del sistema).
    Run, nircmdc screensaver
}
TrayTip, SaveWinPositions, Posiciones de ventanas grabadas para %NumeroDePantallasEsperado% pantalla(s)., ,1
; Beeps report: correctly finished.
    SoundBeep 1500,100
    SoundBeep 1000,100
    SoundBeep 3500,100
sleep 10000

; Funciones del programa
WinGetNormalPos(hwnd, ByRef x, ByRef y, ByRef w="", ByRef h="")
; Devuelve la posición que tendría la ventana si no estuviera minimizada (posición restaurada).
{
    VarSetCapacity(wp, 44), NumPut(44, wp)
    DllCall("GetWindowPlacement", "uint", hwnd, "uint", &wp)
    x := NumGet(wp, 28, "int")
    y := NumGet(wp, 32, "int")
    w := NumGet(wp, 36, "int") - x
    h := NumGet(wp, 40, "int") - y
}