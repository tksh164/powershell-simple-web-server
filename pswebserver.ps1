$listenUri = 'http://*:8080/'
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add($listenUri)
$listener.Start()

try {
    while ($true) {
        Write-Host ('Waiting for incoming request on {0}' -f $listenUri)
        $ctx = $listener.GetContext()

        $json = @{
            timestamp             = (Get-Date -Format 'o')
            webServerComputerName = $env:ComputerName
            #contentLength         = $ctx.Request.ContentLength64
            httpMethod            = $ctx.Request.HttpMethod
            localEndPoint         = '[{0}]:{1}' -f $ctx.Request.LocalEndPoint.Address.ToString(), $ctx.Request.LocalEndPoint.Port
            remoteEndPoint        = '[{0}]:{1}' -f $ctx.Request.RemoteEndPoint.Address.ToString(), $ctx.Request.LocalEndPoint.Port
            isLocal               = $ctx.Request.IsLocal
            queryString           = $ctx.Request.Url.Query
            
        } | ConvertTo-Json
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)

        $ctx.Response.ContentType = 'application/json'
        $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
        $ctx.Response.Close()
    }
}
finally {
    $listener.Stop()
}
