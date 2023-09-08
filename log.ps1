##########################################################################
# ���O�o��
# ���p�Fhttps://www.vwnet.jp/Windows/PowerShell/ExecuteLog.htm�@
##########################################################################
function Log($LogString){

    # ���O�̏o�͐�
    $LogPath = ".\log"

    # ���O�t�@�C����
    $LogName = "ExecutLog"

    # Log �o�͕�����Ɏ�����t��(YYYY/MM/DD HH:MM:SS.MMM $LogString)
    $Now = Get-Date
    $Log = $Now.ToString("yyyy/MM/dd HH:mm:ss.fff") + " "
    $Log += $LogString

    # ���O�t�@�C����(XXXX_YYYY-MM-DD.log)
    $LogFile = $LogName + "_" +$Now.ToString("yyyy-MM-dd") + ".log"

    # ���O�t�H���_�[���Ȃ�������쐬
    if( -not (Test-Path $LogPath) ) {
        New-Item $LogPath -Type Directory
    }

    # ���O�t�@�C����
    $LogFileName = Join-Path $LogPath $LogFile

    # ���O�o��
    Write-Output $Log | Out-File -FilePath $LogFileName -Encoding Default -append

    Return $Log
}