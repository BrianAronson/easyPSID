#' Lookup new longitudinal variables names
#' @description Finds the new name of any longitudinal variable in the PSID Family Files or Individual files following implementation of the rename_fam_vars and rename_ind_vars functions.
#' @param variable Variable to look up
#' @param var_year Report year when renamed variable first entered the PSID dataset (default=TRUE)
#' @keywords PSID
#' @export
#' @examples find_name(variable="V1244",var_year=FALSE)


find_name<-function(variable,var_year=TRUE){
    #1) Make sure variable is in character format
        variable<-as.character(variable)
    #2) Find variable in reference dataset
        varrow<-data$psid_all[which(variable==data$psid_all,arr.ind=T)[1],]
    #3) If variable is not in reference dataset, just show the variable name
        if(all(is.na(varrow))){
          return(variable)
        }
    #4) Otherwise, print variable name and var_year if requested
        #a) Remove var_years where that variable didn't exist
            varrow<-varrow[,varrow!=""]
        #b) Create data table of all var_years and names
            df<-data.frame(Year=substring(names(varrow),2),
                           Name=as.character(unlist(varrow)))
            df$Name<-as.character(df$Name)
            df$Year<-as.numeric(as.character(df$Year))
        #c) Return first row/cell depending on input
            if(var_year==TRUE){
              return(df[1,])
            }
            return(df[1,2])
}
