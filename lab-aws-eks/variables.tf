variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API Token with DNS Edit permissions"
  sensitive   = true
  default     = null
}
