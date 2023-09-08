function ConvertErrorMessage($ExceptionResponse){
    $rs = $ExceptionResponse.Response.GetResponseStream()
    $rs.Position = 0
    $sr = [System.IO.StreamReader]::new($rs)
    $res = $sr.ReadToEnd()
    $sr.Close()
    $message = "StatusCode : {0}, Response : {1}" -f $ExceptionResponse.StatusCode.Value__ ,$res
    return $message
}