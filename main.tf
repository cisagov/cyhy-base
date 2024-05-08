# ------------------------------------------------------------------------------
# Deploy the example AMI from cisagov/skeleton-packer in AWS.
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Look up the latest example AMI from cisagov/skeleton-packer.
#
# NOTE: This Terraform data source must return at least one AMI result
# or the apply will fail.
# ------------------------------------------------------------------------------

# The AMI from cisagov/skeleton-packer
data "aws_ami" "example" {
  filter {
    name = "name"
    values = [
      "example-hvm-*-x86_64-ebs",
    ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  most_recent = true
  owners = [
    var.ami_owner_account_id
  ]
}

# The default tags configured for the default provider
data "aws_default_tags" "default" {}

# The example EC2 instance
resource "aws_instance" "example" {
  ami               = data.aws_ami.example.id
  availability_zone = "${var.aws_region}${var.aws_availability_zone}"
  instance_type     = "t3.micro"
  subnet_id         = var.subnet_id

  # The tag or tags specified here will be merged with the provider's
  # default tags.
  tags = {
    "Name" = "Example"
  }
  # volume_tags does not yet inherit the default tags from the
  # provider.  See hashicorp/terraform-provider-aws#19188 for more
  # details.
  volume_tags = merge(
    data.aws_default_tags.default.tags,
    {
      "Name" = "Example"
    },
  )
}
