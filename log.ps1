##########################################################################
# ログ出力
# 引用：https://www.vwnet.jp/Windows/PowerShell/ExecuteLog.htm　
##########################################################################
function Log($LogString){

    # ログの出力先
    $LogPath = ".\log"

    # ログファイル名
    $LogName = "ExecutLog"

    # Log 出力文字列に時刻を付加(YYYY/MM/DD HH:MM:SS.MMM $LogString)
    $Now = Get-Date
    $Log = $Now.ToString("yyyy/MM/dd HH:mm:ss.fff") + " "
    $Log += $LogString

    # ログファイル名(XXXX_YYYY-MM-DD.log)
    $LogFile = $LogName + "_" +$Now.ToString("yyyy-MM-dd") + ".log"

    # ログフォルダーがなかったら作成
    if( -not (Test-Path $LogPath) ) {
        New-Item $LogPath -Type Directory
    }

    # ログファイル名
    $LogFileName = Join-Path $LogPath $LogFile

    # ログ出力
    Write-Output $Log | Out-File -FilePath $LogFileName -Encoding Default -append

    Return $Log
}