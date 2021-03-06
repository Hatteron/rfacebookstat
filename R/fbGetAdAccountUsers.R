fbGetAdAccountUsers <- function(accounts_id = NULL ,api_version = "v2.10", access_token = NULL){
  
  if(is.null(accounts_id)|is.null(access_token)){
    stop("Arguments accounts_id and access_token is require.")
  }

#check stringAsFactor
factor_change <- FALSE

#change string is factor if TRUE
if(getOption("stringsAsFactors")){
  options(stringsAsFactors = F)
  factor_change <- TRUE
}

#Check account ids
accounts_id <- ifelse(grepl("^act_",accounts_id),accounts_id,paste0("act_",accounts_id))

#result df
result <- data.frame(stringsAsFactors = F)

#Create counter variables
account_number <- 0
error_number   <- 0
 
#Start message
packageStartupMessage("Processing...", appendLF = T)
#
#start cycle
for(account in accounts_id){
  if(is.na(account)|is.null(account)) next
  account_number <- account_number + 1
  
#Compose URL hhtp request
 packageStartupMessage(account, appendLF = F)
 
 QueryString <- paste0("https://graph.facebook.com/",api_version,"/",account,"/userpermissions?fields=user,business_persona,email,role,status&limit=150&access_token=",access_token)

 #Send request
 answer <- GET(QueryString)
 raw <- fromJSON(content(answer, "text", "application/json",encoding = "UTF-8"))
 
 #Check answer on error
 if(length(raw$error) > 0){
   packageStartupMessage(paste0(" - ",raw$error$code, " - ", raw$error$message), appendLF = T)
   error_number   <- error_number + 1
   next
 }

 #Parse answer and transform him to data frame
 flatten_data <- fromJSON(content(answer, "text", "application/json",encoding = "UTF-8"), flatten = T)$data
 
 if(is.null(flatten_data)|length(flatten_data) == 0){
   packageStartupMessage(paste0(" - Empty userlist!"), appendLF = T)
   error_number   <- error_number + 1
   next
 }
  
 #add account id ino data frame 
 flatten_data$account_id <- account
 
 #Add all field list
 if(is.null(flatten_data$email))                 flatten_data$email <- NA
 if(is.null(flatten_data$business.id))           flatten_data$business.id <- NA
 if(is.null(flatten_data$business.name))         flatten_data$business.name <- NA
 if(is.null(flatten_data$business_persona.id))   flatten_data$business_persona.id <- NA
 if(is.null(flatten_data$business_persona.name)) flatten_data$business_persona.name <- NA
 
 #Add to result data.frame
 result <- rbind(result, flatten_data)
 
 packageStartupMessage(paste0(" - Done, ",length(unique(flatten_data$user.id))," users"), appendLF = T)
}

#back string as factor value
if(factor_change){
  options(stringsAsFactors = T)
}
packageStartupMessage("Done", appendLF = T)
packageStartupMessage(paste0("Load userlist from ", account_number - error_number, " accounts."), appendLF = T)
if(error_number > 0) packageStartupMessage(paste0("Error in ", error_number, " accounts."), appendLF = T)
return(result)
}
