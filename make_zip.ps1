if (Test-Path grpc-windows) {
  Remove-Item grpc-windows -recurse
}
if (Test-Path grpc-windows.zip) {
  Remove-Item grpc-windows.zip
}

Copy-Item install grpc-windows\install -recurse

Add-Type -A 'System.IO.Compression.FileSystem'
[IO.Compression.ZipFile]::CreateFromDirectory("${pwd}\grpc-windows", "${pwd}\grpc-windows.zip", [System.IO.Compression.CompressionLevel]::Optimal, $true)
