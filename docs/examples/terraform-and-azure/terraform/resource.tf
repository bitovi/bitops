# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "rg" {
        name = "Demo-rg"
        location = "centralus"
}
