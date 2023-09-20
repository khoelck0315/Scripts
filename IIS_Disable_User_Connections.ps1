# This file is designed to be a template for building Jenkins jobs to enabledisable user connections to a
specified system.  While it can be uncommented and run as necessary, it's cleaner to copy over the pieces
the Jenkins job will use to the configuration page and name the job appropriately #


#############################################################################################################
#    Which site are we disabling connections for Uncommentcopy ONE of the $site variables below...        #
#############################################################################################################

#Dev (only useful for script testing purposes) IMPORTANT make sure job runs on dev webserver
#$site = <IIS Sitename>

#Test (block access to App1 Test, App2 Test) IMPORTANT make sure job runs on test webserver
#$site = <IIS Sitename>

#Production (block access to App1 Prod, App2 Prod)  IMPORTANT make sure job runs on prod webserver
#$site = <IIS Sitename>
#############################################################################################################


#############################################################################################################
#    Use this section to BLOCK user connections to a system.  They will simply receive a 404.  To use this  #
#    method, uncommentcopy the Add-Webconfiguration -OR- Clear-Webconfiguration, depending on the job.     #
#############################################################################################################

#
For reference, below is the XML from the web.config file that this script modifies in order to block users from accessing
the policy systems

security
    requestFiltering
        denyUrlSequences
            add sequence=$block_system   -- Added and deleted by this script
        denyUrlSequences
    requestFiltering
security
#

#Uncommentcopy ONE of these options if BLOCKING access
#------------------------------------------------------
#Block user connections to App1 only
#$block_system = App1

#Block user connections to App2 only
#$block_system = App2;

#Block user connections to both systems
#$block_system = sso;


#The following line will add the above configuration to the web.config xml
#-------------------------------------------------------------------------
#Add-WebConfiguration -filter system.webServersecurityrequestFilteringdenyUrlSequences -AtIndex 0 -pspath IISsites$site -value @{sequence=$block_system}

#The following will restore access to the specified system
#---------------------------------------------------------
#Clear-WebConfiguration -filter system.webServersecurityrequestFilteringdenyUrlSequences -pspath IISsites$site

#############################################################################################################


#############################################################################################################
#    Use this section to REDIRECT user connections to a system to an information page. To use this method,  #
#    uncommentcopy the Add-Webconfiguration -OR- Clear-Webconfiguration, depending on the job.             #
#############################################################################################################

# For reference, below is the XML from the web.config file that this script modifies in order to block users from accessingthe policy systems
rewrite
	rules
		rule name=Redirect user connections enabled=true patternSyntax=Wildcard
			match url=app1 
			action type=Redirect url=$redirect_page appendQueryString=false 
		rule
	rules
rewrite

IMPORTANT The following must be copied into the web.config file before using
(only once, when initially beginning to use this process on a webserver)

outboundRules
    rule name=Require clients to revalidate temporary redirects
	    match serverVariable=RESPONSE_Cache_Control pattern=. 
	    conditions
		    add input={RESPONSE_STATUS} pattern=302 
	    conditions
	    action type=Rewrite value=public, must-revalidate, max-age=0 
    rule
outboundRules

This is necessary to prevent the browser from cacheing the temporary redirect in the session.  Without this outbound rule, the
browser window(not just tab) would have to be closed before being able to access the systems after reaching the redirect page.
#



#Define the relative path to the redirect page that will be displayed when a user tries to access the system
$redirect_page = index.php;

#Uncommentcopy ONE of these options if REDIRECTING users
#--------------------------------------------------------
#Redirect connections for App1 only
#$redirect_system = App1;

#Redirect connections for App2 only
$redirect_system = App2;

#Redirect connections for all systems
#$redirect_system = sso;


#Copyuncomment ALL of the following lines to add the above configuration to the web.config xml
#----------------------------------------------------------------------------------------------
Add-WebConfigurationProperty -filter 'system.webServerrewriterules' -pspath IISsites$site  -name . -value @{name=Redirect; patternSyntax=Wildcard}
Set-WebconfigurationProperty -filter 'system.webServerrewriterulesrule[@name=Redirect]match' -pspath IISsites$site -name . -value @{url=$redirect_system}
Set-WebConfigurationProperty -filter 'system.webServerrewriterulesrule[@name=Redirect]action' -pspath IISsites$site -name .  -value @{type=Redirect; url=$redirect_page; appendQueryString=false; redirectType=Temporary}

#The following will restore access to the specified system
#Clear-WebConfiguration -filter 'system.webServerrewriterulesrule[@name=Redirect]' -pspath IISsites$site

#############################################################################################################