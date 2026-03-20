resource "aws_instance" "node" {
  count = 2

  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_ids[count.index]
  vpc_security_group_ids = [var.app_sg_id]
  key_name               = var.key_name

  user_data_base64 = base64encode(templatefile("${path.module}/install.sh", {
    nodeport_port = var.nodeport_port
  }))

  tags = {
    Name = "${var.name_prefix}-node-${count.index}"
  }
}

resource "aws_lb_target_group_attachment" "node" {
  count = 2

  target_group_arn = var.target_group_arn
  target_id        = aws_instance.node[count.index].id
}
