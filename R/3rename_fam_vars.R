#' Rename longitudinal Family File variables
#' @description Renames all longitudinal variables in every PSID Family File of a given directory, such that variables are labeled with the variable name used when the variable was first made available in the PSID. For example, the "Release Number" variable was first recorded in the PSID dataset in 1968 as variable "V1" but its name in the 1969 family file is "V441". This program changes the "Release Number" variable name to "V1" in 1968 and all subsequent waves.
#' @param in_direc Directory of PSID .rds files to rename
#' @param out_direc Directory for renamed PSID .rds files to be saves to. Warning: If no directory specified, this function will overwrite the Family Files in the current directory.
#' @keywords PSID
#' @export
#' @examples
#' rename_fam_vars(
#'     in_direc=system.file("extdata","rds_dir", package = "easyPSID"),
#'     out_direc=tempdir()
#' )

rename_fam_vars<-function(in_direc,out_direc){
    #1) Deprecate - Set Directory
        # in_direc<-ifelse(is.null(in_direc),getwd(),in_direc)
        # out_direc<-ifelse(is.null(out_direc),getwd(),out_direc)
    #2) Create list of files to alter
        file_names<-list.files(path=in_direc,pattern= c("^FAM.*\\.rds$" ),full.names=T) #only files beginning with title "FAM" and ending with ".rds"
        file_names2<-list.files(path=in_direc,pattern= c("^FAM.*\\.rds$" ))
    #3) For each file:
        for(j in 1:length(file_names)){
        #a) Load first file and rename to "temp_data"
            temp_data<-readRDS(file_names[j])
        #b) Create vector of variable names
            temp_names<-names(temp_data)
        #c) Determine which column to search
            temp_column<-match(gsub('\\D+','', file_names2[j]),substring(names(data$psid_all),2))
        #d) For each year:
          for (i in 1:length(temp_names)){
            #i) Find and list equivalent variables from other years
                temp<-as.matrix(data$psid_all[data$psid_all[,temp_column]==temp_names[i],])
            #ii) Remove years where that variable didn't exist
                temp<-temp[temp!=""]
            #iii) If variable not in list, skip
                if (is.na(temp[1])){
                  next()}
                temp_names[i]<-temp[1] # otherwise replace variable name to name of variable in earliest occurring dataset
          }
    #4) Change names of dataframes
        names(temp_data) <- temp_names
    #5) Save output into same directory and with same name as previously
        dir.create(out_direc, showWarnings = F)
        saveRDS(temp_data, file = paste(out_direc, "/", file_names2[j], sep = ""))
        message(paste(file_names2[j], "renamed"))
        rm(list = c("temp_data"))
      }
}
