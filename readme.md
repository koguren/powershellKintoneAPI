```kintoneDownloadAllFiles.ps1
# sample

# ロギング
.'.\log'

# kintone-api
.'.\kintoneApi'

Log "Start!"

# アクセストークンをヘッダーにセットする
$ApiKey = '{your-kintone-api-token}'
$headers = @{
    'X-Cybozu-API-Token' = $ApiKey
}

# 接続するアプリのアプリID
$ID = '{your-kintone-app-id}'
$fields = $null;

# 対象アプリから全レコード取得する
$KintoneApi = New-Object KintoneApi
$records = $KintoneApi.GetKintoneRecords($ID, $fields, $headers)
for ($i=0; $i -lt $records.Length; $i++){
  $val1 = $records[$i]['val1'].value
}

Log "End."
```