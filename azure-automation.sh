#!/bin/bash

# Using executors identity
az login 

# Adding the CLI extension for spring-cloud 
az extension add --name spring-cloud

# Adding the CLI extension for AppService 
az extension add --name appservice

# get all the parameters for Azure spring cloud/ App service// start/stop/restart

echo "Please Enter 0 for Azure Spring-Cloud and 1 for App Service : "
read $RES

echo "Please Enter 1 for Start, \n 2 for Stop, \n 3 for Restart : "
read $ACT

echo "Input for Environment"
echo "Please Enter 1 for e2e, \n 2 for dev, \n 3 for prod : "
read $ENV

# if Azure Spring-Cloud
if (( "$RES" = 1)); then
  
  # Get all the apps in the Spring-cloud
  ASC_service_list=$();
  




  az resource list 
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

  # az resource list --resource-type Microsoft.Web/sites --query "[].{ID:id}" -o tsv
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
az resource list --resource-type Microsoft.Web/sites --query "[].{ID:id}" -o tsv

az resource list  --tag "environment=e2e" --query "[?type=='Microsoft.Web/sites'] && [].{ID:id}" -o tsv

az resource list  --tag "environment=e2e" --query "[?type=='Microsoft.AppPlatform/Spring'] && [].{ID:id}" -o tsv


# above command lists all the resource based on the type and query upon the result set to give output in a tabular format with the given columns



##Very useful to iterate over the output of the azure CLI command in a script
for APP_ID in $WEB_APP_LIST; do
    echo stopping the web app with ID : $APP_ID
    az webapp start --id $APP_ID
done

#------------------------------------------------------------------------
#!/bin/bash

# Using executors identity
az login 

# Temporarily change the path to private dist
export PATH=:$PATH

# Adding the CLI extension for spring-cloud 
az extension add --name spring-cloud


#-----------------------------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------------------#
#------------------------------------------------------- INPUTS FROM USER ----------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------------------#

# GET THE ENVIRONMENT 

echo "PLEASE ENTER A APPROPRIATE NUMBER FOR SELECTING THE Environment "
echo "Please Enter 1 for e2e, 2 for dev, 3 for prod : "
read $ENV

# FIGURE OUT THE RESOURCE GROUPS
if (( "$ENV" = 1)); then
  $ENV_STRING=e2e
fi
if (( "$ENV" = 2)); then
  $ENV_STRING=dev
fi
if (( "$ENV" = 3)); then
  $ENV_STRING=prod
fi

RG_LIST=$(az group list --query [].{Name:name} -o tsv) 
ENV_RG_LIST=$(echo $RG_LIST | tr ' ' '\n' | grep $ENV_STRING)


# GET THE SERVICE 
echo "Please Enter 1 for Azure Spring-Cloud and 2 for App Service : "
read $SVC

# GET THE ACTION USER WANTS TO PERFORM
echo "Please Enter 1 for Start, \n 2 for Stop, \n 3 for Restart : "
read $ACT

#-----------------------------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------------------#
#------------------------------------------------------- AZURE SPRING CLOUD --------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------------------#

if (( "$SVC" = 1)); then

  for res_gr in $ENV_RG_LIST; do
    # get the list of all the asc resources
    asc_service_name_list=$(az spring-cloud list -g $res_gr --query "[].{Name:name}" -o tsv)
    for service_name in $asc_service_name_list; do
      #get all the apps in each service and then start/stop
      app_names_list=$(az spring cloud app list -s $service_name --query "[].{Name:name}" -o tsv)
      for app_name in app_names_list; do
        if (( "$ACT" = 1)); then
          az spring-cloud app start --name $app_name --service $service_name -g $res_gr
        fi
        if (( "$ACT" = 2)); then
          az spring-cloud app stop --name $app_name --service $service_name -g $res_gr
        fi
        if (( "$ACT" = 3)); then
          az spring-cloud app restart --name $app_name --service $service_name -g $res_gr
        fi
      done
    done
  done

fi


#-----------------------------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------------------#
#------------------------------------------------------- APP SERVICE / WEBAPPS -----------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------------------#

if (( "$SVC" = 2)); then

  for res_gr in $ENV_RG_LIST; do
    # get the list of all the asc resources
    appsvc_service_ID_list=$(az webapp list -g $res_gr --query "[].{ID:id}" -o tsv)
    for app_service_id in $appsvc_service_ID_list; do
      if (( "$ACT" = 1)); then
        az webapp start --id $app_service_id
      fi
      if (( "$ACT" = 2)); then
        az webapp stop --id $app_service_id
      fi
      if (( "$ACT" = 3)); then
        az webapp restart --id $app_service_id
      fi
    done

  done

fi

# # To be deleted after this
# az spring-cloud list -g $res_gr
#  az resource show --ids $IDs 
#echo $env_rg_list | tr ' ' '\n' | grep rg

#  echo stopping the web app with ID : $res_gr