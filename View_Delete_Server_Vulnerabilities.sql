-- Remove all discovered vulnerabilities from Forticlient endpoints

-- Obtain the list of endpoint policies
/*
SELECT * FROM [FCM_Default].[dbo].[endpoint_policies]
*/

-- Select all vulnerabilities that are detected on an endpoint with policy id <id>
/*
SELECT	[FCM_Default].[dbo].[client_vulnerabilities].[vulnerability_id],
		[FCM_Default].[dbo].[client_vulnerabilities].[client_user_id],
	    [FCM_Default].[dbo].[FortiClients_users].[policy_id],
	    [FCM_Default].[dbo].[VULN_details].[title],
	    [FCM_Default].[dbo].[FortiClients].[devices_id],
	    [FCM_Default].[dbo].[Devices].[host]

FROM	[FCM_Default].[dbo].[client_vulnerabilities]

LEFT JOIN
		[FCM_Default].[dbo].[FortiClients_users]
ON	    [FCM_Default].[dbo].[client_vulnerabilities].[client_user_id] = [FCM_Default].[dbo].[FortiClients_users].[id]
	
RIGHT JOIN
		[FCM_Default].[dbo].[VULN_details]
ON		[FCM_Default].[dbo].[client_vulnerabilities].[vulnerability_id] = [FCM_Default].[dbo].[VULN_details].[vid]

RIGHT JOIN
		[FCM_Default].[dbo].[FortiClients]
ON		[FCM_Default].[dbo].[FortiClients].[id] = [FCM_Default].[dbo].[FortiClients_users].[client_id]

RIGHT JOIN
		[FCM_Default].[dbo].[Devices]
ON		[FCM_Default].[dbo].[Devices].[id] = [FCM_Default].[dbo].[FortiClients].[devices_id]

WHERE	[FCM_Default].[dbo].[FortiClients_users].[policy_id] = <id>
*/

-- Delete them, leaving only workstations in the view, not counting servers that get added by mistake
DELETE	[FCM_Default].[dbo].[client_vulnerabilities]
FROM	[FCM_Default].[dbo].[client_vulnerabilities]
 
LEFT JOIN
		[FCM_Default].[dbo].[FortiClients_users]
ON		[FCM_Default].[dbo].[client_vulnerabilities].[client_user_id] = [FCM_Default].[dbo].[FortiClients_users].[id]
-- Add policy id excludes below
WHERE	[FCM_Default].[dbo].[FortiClients_users].[policy_id] != 13
