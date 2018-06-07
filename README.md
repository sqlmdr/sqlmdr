# SQLMDR
[![codecov](https://codecov.io/gh/awickham10/sqlmdr/branch/master/graph/badge.svg)](https://codecov.io/gh/awickham10/sqlmdr)

The **SQLMDR** ( SQL Server Management Data Repository) PowerShell module allows you to save the output of PowerShell functions in a database and track trends over time.

## Functions
* **Disable-MdrCommand** disables collection of a command.
* **Enable-MdrCommand** enables collection of a command.
* **Get-MdrCommand** gets a registered command.
* **Register-MdrCommand** registers a new command for collection.
* **Set-MdrCommand updates** a command's registration (i.e. collection frequency).

## Versions
### Unreleased
* Disable-MdrCommand implementation.
* Enable-MdrCommand implementation.
* Get-MdrCommand implementation.
* Register-MdrCommand implementation.
* Set-MdrCommand implementation.