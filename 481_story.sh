#!/bin/bash

# Using executors identity
az login 

# Adding the CLI extension for spring-cloud 
az extension add --name spring-cloud

# Adding the CLI extension for AppService 
az extension add --name appservice

# get all the parameters for Azure spring cloud/ App service// start/stop/restart

echo "Please Enter 0 for Azure Spring-Cloud and 1 for App Service : "
read $VAR

echo "Please Enter 1 for Start, \n 2 for Stop, \n 3 for Restart : "
read $ACT

# if Azure Spring-Cloud
if (( "$VAR" = 1)); then
  
    # Get all the apps in the Spring-cloud
	az spring-cloud app list -s MyCluster 
							 -g MyResourceGroup 
							 -o json 
							 --query '[].{Name:name, PersistentStorage:properties.persistentDisk}'
  
  if (( "$ACT" = 1)); then
	 echo "Starting the ASC application "
	 az spring-cloud app start --name <app name> 
                          --resource-group <rg name>
                          --service <spring-cloud name>
  fi
  if (( "$ACT" = 2)); then
	 echo "Stopping the ASC application "
     az spring-cloud app stop --name <app name> 
                          --resource-group <rg name>
                          --service <spring-cloud name>
  fi
  if (( "$ACT" = 3)); then
	 echo "Restarting the ASC application "
     az spring-cloud app restart --name <app name> 
                          --resource-group <rg name>
                          --service <spring-cloud name>
  fi

  # if App Service
else
	# Get all the resources of type app service in the firm OR apply filter if needed
  # Output of the above commmand should be in tsv and contains all the IDs of the resources upon 
  # which we run  few actions

	WEB_APP_LIST=$( az webapp list --query '[].{ID:id}' -o tsv )
  
  if (( "$ACT" = 1)); then
	  for APP_ID in $WEB_APP_LIST; do
      echo "starting the web app with ID : $APP_ID"
      az webapp start --id $APP_ID
    done
  fi
  if (( "$ACT" = 2)); then
	  for APP_ID in $WEB_APP_LIST; do
      echo "stopping the web app with ID : $APP_ID"
      az webapp stop --id $APP_ID
    done
  fi
  if (( "$ACT" = 3)); then
	  for APP_ID in $WEB_APP_LIST; do
      echo "Restarting the web app with ID : $APP_ID"
      az webapp restart --id $APP_ID
    done
  fi
fi


# Useful commands to query only using the CLI
az resource list --resource-type Microsoft.Web/sites --query "[].{Name:name, ID:id}" -o tsv
# above command lists all the resource based on the type and query upon the result set to give output in a tabular format with the given columns



##Very useful to iterate over the output of the azure CLI command in a script
for APP_ID in $WEB_APP_LIST; do
    echo stopping the web app with ID : $APP_ID
    az webapp start --id $APP_ID
done
