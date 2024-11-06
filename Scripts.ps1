$Paths = @("D:\.Programs\Scripts\LoaLogs\LoaLogsScript.py")
foreach ($Script in $Paths) {
        Start-Process -FilePath "pythonw.exe" -ArgumentList $Script -WindowStyle Hidden
    }
