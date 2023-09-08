###############################
# kinton-apiのwrapperです     #
# author koguren              #
###############################

# ロギング
.'.\log';

class KintoneApi {

  # kintoneのベースURL
  [string] $URL = 'https://your-domain.cybozu.com';

  # レコード取得API
  [array] GetKintoneRecord($app, $fields, $query, $headers){
  
    $URI = "/k/v1/records.json"
    $Uri = $this.URL + $URI
    
    $body = @{
      app = $app
      query = $query
      fields = $fields
      totalCount = 'true'
    }
    
    $Report = @();
    try {
      Log "Start GetKintoneRecord. app=$app, fields=$fields, query=$query"
      $Report = Invoke-RestMethod -Method Get -Uri $Uri -Body $body -Headers $headers
    } catch {
      Log ($_.Exception)
      Log (ConvertErrorMessage($_.Exception))
    } finally {
      Log 'End GetKintoneRecord'
    }
    
    $records = @();
    for ($i=0; $i -lt $Report.records.Length; $i++){
      $records += $Report.records[$i]
    }
    
    return $records;
  }

  # レコード一括取得API(検索条件指定なし)
  [array] GetKintoneRecords($app, $fields, $headers){
    return $this.GetKintoneRecords($app, $fields, $headers, $null);
  }

  # レコード一括取得API(検索条件指定あり)
  [array] GetKintoneRecords($app, $fields, $headers, $customQuery){

    $URI = "/k/v1/records.json"
    $Uri = $this.URL + $URI
    
    # 検索結果の一番大きなレコード番号を設定する変数、繰り返し検索する際の起点として利用する
    $lastRecordId = 0;
    
    # 検索結果を格納する配列
    $records = @();
    # 検索ループ実行回数
    $Report = @();
    # 1度の検索上限数
    $getLimitSize = 500;

    try {
      Log "Start GetKintoneRecords."
      while($true) {
        $query = 'レコード番号 > ' + $lastRecordId + ' order by レコード番号 asc limit ' + $getLimitSize;
      
        # 検索条件が指定されている場合は設定する(andで結合)
        if (-not ([string]::IsNullOrEmpty($customQuery))){
          $query = $customQuery + ' and ' + $query
        }

        $body = @{
          app = $app
          query = $query
          fields = $fields
          totalCount = 'true'
        }
    
        $Report = Invoke-RestMethod -Method Get -Uri $Uri -Body $body -Headers $headers
      
        for ($i=0; $i -lt $Report.records.Length; $i++){    
          $records += $Report.records[$i]
          $lastRecordId = $Report.records[$i].レコード番号.value
        }
        
        # getLimitSize以下になるまで検索を繰り返す
        if ($Report.records.Length -lt $getLimitSize) {
          break
        }
        
      }

    } catch {
      Log ($_.Exception)
      Log (ConvertErrorMessage($_.Exception))
    } finally {
      Log 'End GetKintoneRecords'
    }
    
    return $records;
  }

  # レコード登録API
  [void] PostKintoneRecord($app, $record, $headers){
  
    $URI = "/k/v1/record.json"
    $Uri = $this.URLURL + $URI
    
    $body = @{
      app = $app
      record = $record
    }
    # json形式変換
    $jsonBody = $body | ConvertTo-Json -Compress
    $SendJson = [System.Text.Encoding]::UTF8.GetBytes($jsonBody)
    
    # kintoneAPI を叩く
    $Report = @();
    try {
      Log "Start PostKintoneRecord. requestBody=$jsonBody"
      $Report = Invoke-RestMethod -Method Post -Uri $Uri -Body $SendJson -Headers $headers -ContentType 'application/json'
    } catch {
      Log ($_.Exception)
      Log (ConvertErrorMessage($_.Exception))
    } finally {
      Log 'End PostKintoneRecord'
    }
  }

  # レコード一括登録API
  [void] PostKintoneRecords($app, $records, $headers){

    $URI = "/k/v1/records.json"
    $Uri = $this.URL + $URI
    
    # APIリクエストするデータセット(最大100件単位)を作成してAPIにPOSTする
    $rArray = @()
    $count = 0;
    $postLimitSize = 100;
    for ($i=0; $i -lt $records.Length; $i++ ) {
      $rArray += $records[$i]
      $count++;
      
      # 100件ずつ分割して送信する
      if ($count -eq $postLimitSize) {
        $body = @{
          app = $app
          records = $rArray
        }
        $jsonBody = $body | ConvertTo-Json -Depth 10
        $compressJsonBody = $body | ConvertTo-Json -Compress -Depth 10 #ログ用
        $SendJson = [System.Text.Encoding]::UTF8.GetBytes($jsonBody)

        $Report = @();
        try {
          Log "Start PostKintoneRecords. requestBody=$compressJsonBody"
          $Report = Invoke-RestMethod -Method Post -Uri $Uri -Body $SendJson -Headers $headers -ContentType 'application/json'
        } catch {
          Log ($_.Exception)
          Log (ConvertErrorMessage($_.Exception))
        } finally {
          Log 'End PostKintoneRecords'
        }
        
        # 初期化
        $rArray = @()
        $count = 0;
      }
    }
    
    # api送信(100件未満)
    $body = @{
      app = $app
      records = $rArray
    }
    $jsonBody = $body | ConvertTo-Json -Depth 10
    $compressJsonBody = $body | ConvertTo-Json -Compress -Depth 10
    $SendJson = [System.Text.Encoding]::UTF8.GetBytes($jsonBody)
    try {
      Log "Start PostKintoneRecords. requestBody=$compressJsonBody"
      $Report = Invoke-RestMethod -Method Post -Uri $Uri -Body $SendJson -Headers $headers -ContentType 'application/json'
    } catch {
      Log ($_.Exception)
      Log (ConvertErrorMessage($_.Exception))
    } finally {
      Log 'End PostKintoneRecords'
    }
  }

  # レコード更新API(1行)
  [void] PutKintoneRecord($app, $record, $headers){
  
    $URI = "/k/v1/record.json"
    $Uri = $this.URL + $URI
    
    $body = @{
      app = $app
      id = $record.id
      record = $record.record
    }
    # json形式変換
    $jsonBody = $body | ConvertTo-Json -Compress
    $compressJsonBody = $body | ConvertTo-Json -Compress -Depth 10
    $SendJson = [System.Text.Encoding]::UTF8.GetBytes($jsonBody)
    $Report = @();
    try {
      Log "Start PutKintoneRecord. requestBody=$compressJsonBody"
      $Report = Invoke-RestMethod -Method Put -Uri $Uri -Body $SendJson -Headers $headers -ContentType 'application/json'
    } catch {
      Log ($_.Exception)
      Log (ConvertErrorMessage($_.Exception))
    } finally {
      Log 'End PutKintoneRecord'
    }
  }

  # レコード一括更新API
  [void] PutKintoneRecords($app, $records, $headers){
    
    $URI = "/k/v1/records.json"
    $Uri = $this.URL + $URI
    
    # APIリクエストするデータセット(最大100件単位で格納する)
    $rArray = @()
    $count = 0;
    $putLimitSize = 100;
    for ($i=0; $i -lt $records.Length; $i++ ) {
      $rArray += $records[$i]
      $count++;
      
      # 100件ずつ分割して送信する
      if ($count -eq $putLimitSize) {
        $body = @{
          app = $app
          records = $rArray
        }
        $jsonBody = $body | ConvertTo-Json -Depth 10
        $compressJsonBody = $body | ConvertTo-Json -Compress -Depth 10
        $SendJson = [System.Text.Encoding]::UTF8.GetBytes($jsonBody)
        $Report = @();
        try {
          Log "Start PutKintoneRecords. requestBody=$compressJsonBody"
          $Report = Invoke-RestMethod -Method Put -Uri $Uri -Body $SendJson -Headers $headers -ContentType 'application/json'
        } catch {
          Log ($_.Exception)
          Log (ConvertErrorMessage($_.Exception))
        } finally {
          Log 'End PutKintoneRecords'
        }
        
        # 初期化
        $rArray = @()
        $count = 0;
      }
    }
    
    # api送信(100件未満)
    $body = @{
      app = $app
      records = $rArray
    }
    $jsonBody = $body | ConvertTo-Json -Depth 10
    $compressJsonBody = $body | ConvertTo-Json -Compress -Depth 10
    $SendJson = [System.Text.Encoding]::UTF8.GetBytes($jsonBody)
    $Report = @();
    try {
      Log "Start PutKintoneRecords. requestBody=$compressJsonBody"
      $Report = Invoke-RestMethod -Method Put -Uri $Uri -Body $SendJson -Headers $headers -ContentType 'application/json'
    } catch {
      Log ($_.Exception)
      Log (ConvertErrorMessage($_.Exception))
    } finally {
      Log 'End PutKintoneRecords'
    }
  }

  # レコード一括削除API
  [void] DeleteKintoneRecords($app, $records, $headers){
  
    $URI = "/k/v1/records.json"
    $Uri = $this.URL + $URI
    
    # APIリクエストするデータセット(最大100件単位で格納する)
    $rArray = @()
    $count = 0;
    for ($i=0; $i -lt $records.Length; $i++ ) {
      $rArray += $records[$i]
      $count++;
      
      # 100件ずつ分割して送信する
      if ($count -eq 100) {
        $body = @{
          app = $app
          ids = $rArray
        }
        $jsonBody = $body | ConvertTo-Json -Depth 10
        $compressJsonBody = $body | ConvertTo-Json -Compress -Depth 10
        $SendJson = [System.Text.Encoding]::UTF8.GetBytes($jsonBody)
        $Report = @();
        try {
          Log "Start DeleteKintoneRecords. requestBody=$compressJsonBody"
          $Report = Invoke-RestMethod -Method Delete -Uri $Uri -Body $SendJson -Headers $headers -ContentType 'application/json'
        } catch {
          Log ($_.Exception)
          Log (ConvertErrorMessage($_.Exception))
        } finally {
          Log 'End DeleteKintoneRecords'
        }
        
        # 初期化
        $rArray = @()
        $count = 0;
      }
    }
    
    # api送信(100件未満)
    $body = @{
      app = $app
      ids = $rArray
    }
    $jsonBody = $body | ConvertTo-Json -Depth 10
    $compressJsonBody = $body | ConvertTo-Json -Compress -Depth 10
    $SendJson = [System.Text.Encoding]::UTF8.GetBytes($jsonBody)
    $Report = @();
    try {
      Log "Start DeleteKintoneRecords. requestBody=$compressJsonBody"
      $Report = Invoke-RestMethod -Method Delete -Uri $Uri -Body $SendJson -Headers $headers -ContentType 'application/json'
    } catch {
      Log ($_.Exception)
      Log (ConvertErrorMessage($_.Exception))
    } finally {
      Log 'End DeleteKintoneRecords'
    }
  }

}