; RestoreWinPositions
; Version v0.22

FileDelete, %TEMP%\WinPosWorking.txt
FileCopy, %TEMP%\WinPos.txt, %TEMP%\WinPosWorking.txt

FileGetTime, FechaOriginal, %TEMP%\WinPos.txt
TiempoTranscurrido := A_Now-FechaOriginal

ArrayCount = 0
if TiempoTranscurrido>5     ; Disparo correcto del salvapantallas: activado/apagado no a la misma vez.
{
    Loop, Read, %TEMP%\WinPosWorking.txt   ; This loop retrieves each line from the file, one at a time.
    {
        ArrayCount += 1  ; Keep track of how many items are in the array.
        Array%ArrayCount% := A_LoopReadLine  ; Store this line in the next array element.
    }
    FileAppend, % "# " . A_YYYY . "-" . A_MM . "-" . A_DD . " " . A_Hour . ":" . A_Min . ":" . A_Sec . " --> " . "RestoreWinPositions:--> Fichero de posiciones creado hace " . TiempoTranscurrido . " segundos (Correcto). Restaurando ventanas...." . " `n", %TEMP%\WinPositions-Log.txt
    TrayTip, RestoreWinPositions, Restaurando ventanas..., ,1
}

if TiempoTranscurrido<=5        ; Disparo en falso del salvapantallas: activado/apagado (casi) a la misma vez.
{
    FileAppend, % "# " . A_YYYY . "-" . A_MM . "-" . A_DD . " " . A_Hour . ":" . A_Min . ":" . A_Sec . " --> " . "RestoreWinPositions:--> Fichero de posiciones creado hace " . TiempoTranscurrido . " segundos (demasiado reciente): Salvapantallas activado en falso. Abortando..." . " `n", %TEMP%\WinPositions-Log.txt
    TrayTip, RestoreWinPositions, Fichero de posiciones crado hace %TiempoTranscurrido% segundos (demasiado reciente): Salvapantallas activado en falso. Abortando., ,2
    sleep 10000
    Exit 1
}

NumParametros = %0%
If ( NumParametros>0 )
{
    Parametro1 = %1%
}
NumeroDePantallasEsperado:=1    ; El sistema dispone de este número de pantallas en total. No se deben mover ventanas ni grabar sus posiciones si no están encendidas todas.
    ;Nótese que este será el valor por defecto de no ser especificado mediante parámetro en la línea de comandos ni existir %A_WorkingDir%\screens.cfg.
If ( NumParametros<1 )  ; Comprobamos el número de parámetros.
{       ; Si no hay parámetros, capturamos el número de pantallas del fichero de configuración (por defecto en el directorio de ejecución del programa), si existe:
    IfExist, screens.cfg    ; Si existe el fichero de configuración...
    {   ; ... leemos de él el número de pantallas esperado.
        FileReadLine,NumeroDePantallasEsperado,%A_WorkingDir%\screens.cfg,1
        FileAppend, % "# " . A_YYYY . "-" . A_MM . "-" . A_DD . " " . A_Hour . ":" . A_Min . ":" . A_Sec . " --> " . "RestoreWinPositions:--> No se introdujeron parámetros, se utilizará el extraído del fichero de configuración.`n", %TEMP%\WinPositions-Log.txt
    } else
    {
        FileAppend, % "# " . A_YYYY . "-" . A_MM . "-" . A_DD . " " . A_Hour . ":" . A_Min . ":" . A_Sec . " --> " . "RestoreWinPositions:--> No existe el fichero de configuración.`n", %TEMP%\WinPositions-Log.txt
    }
} else
{   ; Si hay parámetros...
    If ( Parametro1 = 0 )   ; si el parámetro es un 0...
    {   ; Ignorar número de monitores
    IgnoreNumPantallas = 1
    FileAppend, % "# " . A_YYYY . "-" . A_MM . "-" . A_DD . " " . A_Hour . ":" . A_Min . ":" . A_Sec . " --> " . "RestoreWinPositions:-> Ignorando número de monitores: se ejecutará el programa sin esperarlos.`n", %TEMP%\WinPositions-Log.txt
    } else
    {   ; si el parámetro es distinto de 0...
        ; ... el parámetro contiene el número de pantallas esperado:
        NumeroDePantallasEsperado = %1%
    }
}
If ( not IgnoreNumPantallas )   ; a menos que se ignore el número de monitores...
{   ; ... añadimos una entrada al log con el número de pantallas necesarias.
    FileAppend, % "# " . A_YYYY . "-" . A_MM . "-" . A_DD . " " . A_Hour . ":" . A_Min . ":" . A_Sec . " --> " . "RestoreWinPositions:--> El sistema debe tener al menos " . NumeroDePantallasEsperado " pantalla(s).`n", %TEMP%\WinPositions-Log.txt
}
; Comprobamos que estén todos los monitores conectados:
SysGet, m, MonitorCount
If ( m < NumeroDePantallasEsperado )    ; Si no están todas las pantallas todavía activas...
{   ; ... esperamos a que se enciendan.
    FileAppend, % "# " . A_YYYY . "-" . A_MM . "-" . A_DD . " " . A_Hour . ":" . A_Min . ":" . A_Sec . " --> " . "RestoreWinPositions:-> Esperando a que el sistema tenga al menos " . NumeroDePantallasEsperado " pantalla(s).`n", %TEMP%\WinPositions-Log.txt
    InicioEspera := A_Now
    TrayTip, RestoreWinPositions, Esperando que estén encendidas %NumeroDePantallasEsperado% pantallas., ,1
}
While ( not IgnoreNumPantallas and m < NumeroDePantallasEsperado )
{
    SysGet, m, MonitorCount
    Ahora := A_Now
    TiempoLimite := 180 ; Tiempo límite en segundos para esperar a que se enciendan todas las pantallas.
    If ( Ahora>InicioEspera+TiempoLimite )
    {   ; Superado tiempo de espera por pantallas.
        FileAppend, % "# " . A_YYYY . "-" . A_MM . "-" . A_DD . " " . A_Hour . ":" . A_Min . ":" . A_Sec . " --> " . "RestoreWinPositions:-> No están listas las " . NumeroDePantallasEsperado . " pantallas transcurrido el tiempo límite. Cancelando la ejecución del programa.`n", %TEMP%\WinPositions-Log.txt
        TrayTip, RestoreWinPositions, Transcurrido tiempo límite (%TiempoLimite% segundos) esperando que estén encendidas %NumeroDePantallasEsperado% pantallas. Abortando., ,2
        sleep 10000
        Exit ,3     ; No están todas las pantallas transcurridos 3 minutos. Cancelamos la ejecución del programa.
    }
}

; Variable para comprobación de que todas las ventanas han sido corréctamente movidas:
Checking := 0
IncorrectPositionWindows := 65536   ; Just to enter the While loop.

; Repetir hasta que ninguna ventana haya tenido que ser movida.
While IncorrectPositionWindows>0
{
    If Checking>0
    {
        FileAppend, % "# " . A_YYYY . "-" . A_MM . "-" . A_DD . " " . A_Hour . ":" . A_Min . ":" . A_Sec . " --> " . "RestoreWinPositions:--> Alguna(s) ventana(s) no estaban en su posición correcta. Revisando; pasada número " . Checking+1 . " ...." . " `n", %TEMP%\WinPositions-Log.txt
    }
    ; Inicializaciones de variables
    CorrectPositionWindows := 0
    IncorrectPositionWindows := 0

    ; Read from the array:
    Loop %ArrayCount%
    {       ; Extraemos línea a línea los datos de cada ventana individual
        Ventana := Array%A_Index%  ; Todos los datos de la ventana serán almacenados en esta variable.
        coma = ,

        ; Extraemos el ID de la ventana.
        Position := InStr(Ventana, coma)
        StringMid, ID, Ventana, 0, Position-1
        StringTrimLeft, Ventana, Ventana, Position
        ; Extraemos la coordenada X de la ventana.
        Position := InStr(Ventana, coma)
        StringMid, x, Ventana, 0, Position-1
        StringTrimLeft, Ventana, Ventana, Position
        ; Extraemos la coordenada Y de la ventana.
        Position := InStr(Ventana, coma)
        StringMid, y, Ventana, 0, Position-1
        StringTrimLeft, Ventana, Ventana, Position
        ; Extraemos el ancho W de la ventana.
        Position := InStr(Ventana, coma)
        StringMid, w, Ventana, 0, Position-1
        StringTrimLeft, Ventana, Ventana, Position
        ; Extraemos el alto H de la ventana.
        Position := InStr(Ventana, coma)
        StringMid, h, Ventana, 0, Position-1
        StringTrimLeft, Ventana, Ventana, Position
        ; Extraemos el título (lo que quede en el string) de la ventana.
        Titulo := Ventana

        WinGetPos,actualx,actualy,actualw,actualh,ahk_id %ID%
        WinGet, WinStatus, MinMax, ahk_id %ID%
        if WinStatus = -1   ; Si la ventana está minimizada...
        {   ; Tratamos de obtener sus coordenadas restauradas sin tener que restaurarla.
            WinGetNormalPos(ID, actualx, actualy, actualw, actualh)
        }

        If (x=actualx and y=actualy and w=actualw and h=actualh)    ; Si la ventana ya tiene sus coordenadas finales...
        {   ; Incrementamos el contador de ventanas que ya estaban en su posición correcta (no ha sido necesario moverla).
            CorrectPositionWindows := ++CorrectPositionWindows
        } else
        {   IfWinExist, ahk_id %ID% ; Actuaremos sobre la ventana tan solo si la ventana existe.
            {   ; Incrementamos el contador de ventanas que no están en su posición correcta (es necesario moverla).
                IncorrectPositionWindows := ++IncorrectPositionWindows
                FileAppend, % "# " . A_YYYY . "-" . A_MM . "-" . A_DD . " " . A_Hour . ":" . A_Min . ":" . A_Sec . " --> " . "RestoreWinPositions:-->  Moviendo ventana " . Titulo . " de coordenadas (X,Y,W,H): " . actualx . "," . actualy . "," . actualw . "," . actualh . " a coordenadas (X,Y,W,H): " . x . "," . y . "," . w . "," . h . "." . " `n", %TEMP%\WinPositions-Log.txt
                If WinStatus = -1   ; Si la ventana está minimizada...
                {   ; No hay más remedio que restaurarla, moverla, y minimizarla de nuevo (No disponemos de métodos para cambiar las coordenadas de restauración para una ventana minimizada).
                    WinRestore, ahk_id %ID%
                    WinMove, ahk_id %ID%, , x, y, w, h
                    WinMinimize, ahk_id %ID%
                } else
                {   ; Si la ventana no está minimizada, nos basta con moverla.
                WinMove, ahk_id %ID%, , x, y, w, h
                }
            } else  ; Si la ventana no existe...
            {   ; prescindimos de actuar sobre esta ventana.
                FileAppend, % "# " . A_YYYY . "-" . A_MM . "-" . A_DD . " " . A_Hour . ":" . A_Min . ":" . A_Sec . " --> " . "RestoreWinPositions:-->  Omitiendo ventana inexistente: " . Titulo . ". `n", %TEMP%\WinPositions-Log.txt
            }
        }
    }
    If Checking>=10 ; ¿Llevamos más de 10 pasadas intentando poner las ventanas en su sitio?
    {   ; Cancelamos
        FileAppend, % "# " . A_YYYY . "-" . A_MM . "-" . A_DD . " " . A_Hour . ":" . A_Min . ":" . A_Sec . " --> " . "RestoreWinPositions:--> Demasiados intentos de ubicar ventanas. Abortando. :-( `n", %TEMP%\WinPositions-Log.txt
        TrayTip, RestoreWinPositions, Demasiados intentos de ubicar ventanas. Abortando. :-( , ,1
        sleep 10000
        Exit 2
    }
    FileAppend, % "# " . A_YYYY . "-" . A_MM . "-" . A_DD . " " . A_Hour . ":" . A_Min . ":" . A_Sec . " --> " . "RestoreWinPositions:-->  Ventanas que ya estaban en su posición correcta: " . CorrectPositionWindows . ". `n", %TEMP%\WinPositions-Log.txt
    FileAppend, % "# " . A_YYYY . "-" . A_MM . "-" . A_DD . " " . A_Hour . ":" . A_Min . ":" . A_Sec . " --> " . "RestoreWinPositions:-->  Ventanas reubicadas: " . IncorrectPositionWindows . ". `n", %TEMP%\WinPositions-Log.txt
    Checking := ++Checking
}
FileAppend, % "# " . A_YYYY . "-" . A_MM . "-" . A_DD . " " . A_Hour . ":" . A_Min . ":" . A_Sec . " --> " . "RestoreWinPositions:--> Ventanas reubicadas corréctamente. Saliendo del programa. :-) `n", %TEMP%\WinPositions-Log.txt
TrayTip, RestoreWinPositions, Ventanas reubicadas corréctamente. Saliendo del programa. :-), ,1
; Beeps report: correctly finished.
    SoundBeep 1500,100
    SoundBeep 1000,100
    SoundBeep 3500,100
sleep 10000


; Funciones utilizadas por el programa.

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