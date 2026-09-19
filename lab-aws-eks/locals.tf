locals {
  env = "dev"

  eks_name    = "${local.env}-eks"
  eks_version = "1.36"

  region   = "eu-west-1"
  vpc_cidr = "10.20.0.0/16"

  public_subnets = {
    public_1 = {
      cidr_block        = cidrsubnet(local.vpc_cidr, 8, 1)
      availability_zone = "${local.region}a"
    }
    public_2 = {
      cidr_block        = cidrsubnet(local.vpc_cidr, 8, 2)
      availability_zone = "${local.region}b"
    }
  }

  private = false

  private_subnets = {
    private_1 = {
      cidr_block        = cidrsubnet(local.vpc_cidr, 8, 101)
      availability_zone = "${local.region}a"
    }
    private_2 = {
      cidr_block        = cidrsubnet(local.vpc_cidr, 8, 102)
      availability_zone = "${local.region}b"
    }
  }
}
