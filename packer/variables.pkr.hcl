variable "atl_product_edition" {
  default = env("ATL_PRODUCT_EDITION")
}

variable "atl_product_version" {
  default = env("ATL_PRODUCT_VERSION")
}

variable "postgresql_major_version" {
  default = env("POSTGRESQL_MAJOR_VERSION")
}

variable "datadog_api_key" {
  default = env("DATADOG_API_KEY")
}

variable "atl_install_jsd_as_obr" {
  default = env("ATL_JSD_ASOBR")
}
