# sample

# ���M���O
.'.\log'

# kintone-api
.'.\kintoneApi'

Log "Start!"

# �A�N�Z�X�g�[�N�����w�b�_�[�ɃZ�b�g����
$ApiKey = '{your-kintone-api-token}'
$headers = @{
    'X-Cybozu-API-Token' = $ApiKey
}

# �ڑ�����A�v���̃A�v��ID
$ID = '{your-kintone-app-id}'
$fields = $null;

# �ΏۃA�v������S���R�[�h�擾����
$KintoneApi = New-Object KintoneApi
$records = $KintoneApi.GetKintoneRecords($ID, $fields, $headers)
for ($i=0; $i -lt $records.Length; $i++){
  $val1 = $records[$i]['val1'].value
}

Log "End."