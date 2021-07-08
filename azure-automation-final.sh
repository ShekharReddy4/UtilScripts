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