locals {
  region   = "eu-west-1"
  vpc_cidr = "10.0.0.0/16"
  env      = "dev"
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

  fqdn = "old-company.org"

}
