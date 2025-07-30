type = "csi"
id = "juicefs-volume"
name = "juicefs-volume"

capability {
access_mode = "multi-node-multi-writer"
attachment_mode = "file-system"
}
plugin_id = "juicefs0"

secrets {
  name="juicefs-volume"
  metaurl="redis://jfs-metadata.service.consul.demophoon.com:19736"
  bucket="https://s3.internal.demophoon.com/juicefs-csi"
  storage="minio"
  access-key="8cUNjvmeMoGLxJ69"
  secret-key="UJbwp08fOQECVBLk9m3LwAF0MdyQisOY"
}
