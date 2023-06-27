resource "aws_key_pair" "tfkey" {
  key_name   = "tf-key"
  public_key = file(var.PUB_KEY_PATH)
}
