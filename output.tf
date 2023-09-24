output "s3_bucket_id" {
  description = "The name of the bucket."
  value       = aws_s3_bucket.sftp_bucket.arn
}

output "Transfer_srv_username" {
  description = "This is the transfer server UserName!"
  value       = aws_transfer_user.transfer_user.user_name
}


output "Transfer_srv_endpoint" {
  description = "This is the transfer server Endpoint!"
  value       = aws_transfer_server.sftp_srv.endpoint
}



