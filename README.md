# Intune Computer State
PowerShell Script to review status of Powershell, Applications, Configuration, and Compliance Policies.

Before a recent client deployment I wrote this module to allow for easy inventory of comptuers as they are building.

UPN is of the email address of the user you are wanting to inventory

Useremail is of the Admin credentials for the tenant.

To execute use this command: get-IntuneComputerState -UPN "usera@onpremcloudguy.com" -useremail "Steven@onpremcloudguy.com" -authMethod AutoInteractive