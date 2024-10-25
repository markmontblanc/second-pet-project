resource "aws_ecs_cluster" "petp_cluster" {
  name = "petp-cluster-${terraform.workspace}"

  tags = {
    Name = "petp-cluster-${terraform.workspace}"
  }
}
