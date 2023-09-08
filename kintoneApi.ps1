###############################
# kinton-api��wrapper�ł�     #
# author koguren              #
###############################

# ���M���O
.'.\log';

class KintoneApi {

  # kintone�̃x�[�XURL
  [string] $URL = 'https://your-domain.cybozu.com';

  # ���R�[�h�擾API
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

  # ���R�[�h�ꊇ�擾API(���������w��Ȃ�)
  [array] GetKintoneRecords($app, $fields, $headers){
    return $this.GetKintoneRecords($app, $fields, $headers, $null);
  }

  # ���R�[�h�ꊇ�擾API(���������w�肠��)
  [array] GetKintoneRecords($app, $fields, $headers, $customQuery){

    $URI = "/k/v1/records.json"
    $Uri = $this.URL + $URI
    
    # �������ʂ̈�ԑ傫�ȃ��R�[�h�ԍ���ݒ肷��ϐ��A�J��Ԃ���������ۂ̋N�_�Ƃ��ė��p����
    $lastRecordId = 0;
    
    # �������ʂ��i�[����z��
    $records = @();
    # �������[�v���s��
    $Report = @();
    # 1�x�̌��������
    $getLimitSize = 500;

    try {
      Log "Start GetKintoneRecords."
      while($true) {
        $query = '���R�[�h�ԍ� > ' + $lastRecordId + ' order by ���R�[�h�ԍ� asc limit ' + $getLimitSize;
      
        # �����������w�肳��Ă���ꍇ�͐ݒ肷��(and�Ō���)
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
          $lastRecordId = $Report.records[$i].���R�[�h�ԍ�.value
        }
        
        # getLimitSize�ȉ��ɂȂ�܂Ō������J��Ԃ�
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

  # ���R�[�h�o�^API
  [void] PostKintoneRecord($app, $record, $headers){
  
    $URI = "/k/v1/record.json"
    $Uri = $this.URLURL + $URI
    
    $body = @{
      app = $app
      record = $record
    }
    # json�`���ϊ�
    $jsonBody = $body | ConvertTo-Json -Compress
    $SendJson = [System.Text.Encoding]::UTF8.GetBytes($jsonBody)
    
    # kintoneAPI ��@��
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

  # ���R�[�h�ꊇ�o�^API
  [void] PostKintoneRecords($app, $records, $headers){

    $URI = "/k/v1/records.json"
    $Uri = $this.URL + $URI
    
    # API���N�G�X�g����f�[�^�Z�b�g(�ő�100���P��)���쐬����API��POST����
    $rArray = @()
    $count = 0;
    $postLimitSize = 100;
    for ($i=0; $i -lt $records.Length; $i++ ) {
      $rArray += $records[$i]
      $count++;
      
      # 100�����������đ��M����
      if ($count -eq $postLimitSize) {
        $body = @{
          app = $app
          records = $rArray
        }
        $jsonBody = $body | ConvertTo-Json -Depth 10
        $compressJsonBody = $body | ConvertTo-Json -Compress -Depth 10 #���O�p
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
        
        # ������
        $rArray = @()
        $count = 0;
      }
    }
    
    # api���M(100������)
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

  # ���R�[�h�X�VAPI(1�s)
  [void] PutKintoneRecord($app, $record, $headers){
  
    $URI = "/k/v1/record.json"
    $Uri = $this.URL + $URI
    
    $body = @{
      app = $app
      id = $record.id
      record = $record.record
    }
    # json�`���ϊ�
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

  # ���R�[�h�ꊇ�X�VAPI
  [void] PutKintoneRecords($app, $records, $headers){
    
    $URI = "/k/v1/records.json"
    $Uri = $this.URL + $URI
    
    # API���N�G�X�g����f�[�^�Z�b�g(�ő�100���P�ʂŊi�[����)
    $rArray = @()
    $count = 0;
    $putLimitSize = 100;
    for ($i=0; $i -lt $records.Length; $i++ ) {
      $rArray += $records[$i]
      $count++;
      
      # 100�����������đ��M����
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
        
        # ������
        $rArray = @()
        $count = 0;
      }
    }
    
    # api���M(100������)
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

  # ���R�[�h�ꊇ�폜API
  [void] DeleteKintoneRecords($app, $records, $headers){
  
    $URI = "/k/v1/records.json"
    $Uri = $this.URL + $URI
    
    # API���N�G�X�g����f�[�^�Z�b�g(�ő�100���P�ʂŊi�[����)
    $rArray = @()
    $count = 0;
    for ($i=0; $i -lt $records.Length; $i++ ) {
      $rArray += $records[$i]
      $count++;
      
      # 100�����������đ��M����
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
        
        # ������
        $rArray = @()
        $count = 0;
      }
    }
    
    # api���M(100������)
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