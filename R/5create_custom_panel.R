#' Create custom longitudinal (panel) dataset with PSID Family Files
#' @description Uses the longitudinal PSID Family Files to create a custom longitudinal dataset in long format based on all PSID .rds Family files in a selected directory.
#' 
#' This function can work with data that has been renamed via the rename_fam_vars function or data just converted to .rds format via the convert_to_rds function. It will creates NAs for years when a given variable was not available, and creates a new variable ("Year") to specify the panel of data included in the custom dataset. If a provided variable exists in other waves of the family files under a different name, all waves of that variable will be included in the resulting dataset.
#' 
#' To create a longitudinal family file of the PSID with all variables in the PSID Family Files, it is recommended that one uses the create_extract function instead. However, such a file can be very large when using many waves of the PSID. Users with more than five waves of the PSID Family Files are highly recommended to avoid creating a longitudinal dataset with all unique Family File variables.
#' 
#' @param var_names Variable names to include in custom longitudinal dataset (as vector of strings)
#' @param in_direc Directory of PSID .rds to use for custom longitudinal dataset
#' @param out_direc Directory to place resulting longitudinal dataset into
#' @keywords PSID
#' @export
#' @examples 
#' create_custom_panel(
#'    var_names = c("V534", "V442", "V398"),
#'    in_direc=system.file("extdata","rds_dir", package = "easyPSID"),
#'    out_direc=tempdir()
#' )

create_custom_panel<-function(var_names, in_direc, out_direc){
    #1) Assign directories
        # in_direc<-ifelse(is.null(in_direc),getwd(),in_direc)
        # out_direc<-ifelse(is.null(out_direc),getwd(),out_direc)
        filenames<-list.files(path=in_direc,pattern= c("^FAM.*\\.rds$" ),full.names = T)
        filenames2<-list.files(path=in_direc,pattern= c("^FAM.*\\.rds$" ))
    #2) Error checks
        #a) Subset variables dataframe to lines that contain variable names.
            variables_temp<-as.matrix(data$psid_all)
        #b) Check if each variable is in the dataset. Break if any variable missing.
            missings<-var_names[is.na(match(var_names,variables_temp))]
            if(length(missings)>0){
                message<-paste("The following variable(s) were not found in the PSID family files:",paste(missings,collapse = ", "),sep="\n\n")
                stop(message)
            }
        #c) Exclude redundant variables from following functions. Post warning.
            redundant<-duplicated(var_names)
            if(any(redundant)){
                redundant_name<-var_names[redundant]
                message<-paste("The following variable(s) were requested more than once. Only one copy of each of these variable(s) will be included in the resulting dataset:",paste(redundant_name,collapse = ", "), sep="\n\n")
                var_names<-var_names[!redundant]
                warning(message)
            }
    #3) Temporarily rename each variable to match names of their earliest occurrence.
        temp_names<-var_names
        #a) Identify row and column of each variable
            index<-lapply(temp_names,function(x) which(data$psid_all==x,arr.ind=T))
        #b) Extract rows from index
            row<-sapply(index,function(x) x[1])
        #c) Keep index of current variables
            new_ind<-data$psid_all[row,]
        #d) Rename columms
            names(new_ind)<-gsub('\\D+','', names(new_ind))
        #e) Identify earliest name of each variable
            early_name<-as.vector(apply(new_ind,1,function(x) x[x!=""][1]))

    #4) Create a list of longitudinal datasets with variables selected above
        temp_datal<-list()
        for(j in 1:length(filenames)){
        #a) Load first file and rename to "temp_data"
            temp_data<-readRDS(filenames[j])
        #b) Create vector of variable names
            temp_names<-names(temp_data)
        #c) Only keep columns that match possible variable names
            #i) Identify dataframe year
                temp_year<-gsub('\\D+','', filenames2[j])
            #ii) Identify matchin column in dataset
                column<-match(temp_year,names(new_ind))
            #iii) Find variable names of requested variables as of a given year
                keep_vars<-match(new_ind[,column],temp_names)
                # In case variables already renamed, try above with earliest variable names
                    keep_varsalt<-match(early_name,temp_names)
                    if(sum(is.na(keep_varsalt))<sum(is.na(keep_vars))){
                      keep_vars<-keep_varsalt
                    }
            #iv) Pull those variables and replace no matches with NAs
                keep_vars2<-keep_vars
                keep_vars2[is.na(keep_vars)]<-1
                temp_data2<-temp_data[,keep_vars2]
                temp_data2[,is.na(keep_vars)]<-NA
            #v) rename variables, add year, and append to list
                names(temp_data2)<-var_names
                temp_data2$Year<-as.numeric(temp_year)
                temp_datal[[j]]<-temp_data2
                message(paste(filenames2[j],"Added to Panel"))
        }
    #5) Put above datasets to dataframe format and save
        PSIDPanel<-do.call(rbind,temp_datal)
        dir.create(out_direc,showWarnings = F)
        saveRDS(PSIDPanel,file=paste(out_direc,"/","PSID Panel.rds",sep = ""))
}
