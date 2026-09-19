locals {
  fqdn = "old-company.org"
  env  = "dev"

  region   = "eu-west-1"
  vpc_cidr = "10.10.0.0/16"

  public_subnets = {
    public_1 = {
      cidr_block        = cidrsubnet(local.vpc_cidr, 8, 1)
      availability_zone = "${local.region}a"
    }
    public_2 = {
      cidr_block        = cidrsubnet(local.vpc_cidr, 8, 2)
      availability_zone = "${local.region}b"
    }
    public_3 = {
      cidr_block        = cidrsubnet(local.vpc_cidr, 8, 3)
      availability_zone = "${local.region}c"
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
    private_3 = {
      cidr_block        = cidrsubnet(local.vpc_cidr, 8, 103)
      availability_zone = "${local.region}c"
    }
  }
}
