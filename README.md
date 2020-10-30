# SignalFx-PowerShell

_This is a PowerShell wrapper around the SignalFx API._

![](https://github.com/StackExchange/signalfx-powershell/workflows/CI/badge.svg)

## Usage

### API Tokens

The _cmdlets_ have an `ApiToken` parameter or the client will try to load tokens from `Env:\`.
The client will loads the appropriate token necessary for the _cmdlet_ from the environment if it's defined.

* **Org tokens - aka Access Tokens**
  * `SFX_ACCESS_TOKEN`
* **Session tokens - aka User API Access Tokens**
  * `SFX_USER_TOKEN`

You can also use `Set-SFxToken` to set either or both environment variables.

SignalFx [documentation](https://developers.signalfx.com/basics/authentication.html) on API Authentication.

### Cmdlets

* **Get-SFxDimensionMetadata** - Retrieves metadata objects for which the metrics name matches the search criteria.
* **Publish-SFxEvent** - Sends custom events to SignalFx.
* **Get-SFxAlertMuting** - Retrieves alerting muting rules based on search criteria.
* **New-SFxAlertMuting** - Creates a new alert muting rule.
* **Publish-SFxMetricBackfill** - Sends historical MTS to SignalFx.
* **Get-SFxMember** - Retrieves one or more members of the organization, based on the search criteria specified in the query parameters.
* **New-SFxMember** - Invites a SignalFx user to the organization. To make this request, you must have administrative access for this organization.
* **Remove-SFxMember** - Remove a SignalFx user from the organization using their member ID. To make this request, you must have administrative access.
* **Get-SFxIncidents** - Retrieves the information for all incidents in an organization.
* **Get-SFxIncidentsReport** - _Experimental_. Generates a couple simple, precanned reports about recent Incidents.
* **Clear-SFxIncident** - Manually clears the incident identified by the SignalFx-assigned incident ID.
