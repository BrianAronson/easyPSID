#' Find years of PSID variable
#' @description Finds the years and corresponding variable names for any longitudinal PSID variable in the PSID Family Files and Individual file.
#' @param variable Variable name to look up
#' @param var_names Report names for longitudinal PSID variable across years (default=TRUE)
#' @keywords PSID
#' @export
#' @examples find_years(variable="V3",var_names=FALSE)


find_years<-function(variable,var_names=TRUE){
    #1) Make sure variable is in character format
        variable<-as.character(variable)
    #2) Find variable in reference dataset
        varrow<-data$psid_all[which(variable==data$psid_all,arr.ind=T)[1],]
    #3) If variable is not in reference dataset, just show the variable name
        if(all(is.na(varrow))){
          return(variable)
        }
    #4) Otherwise, print variable name and year if requested
        #a) Remove years where that variable didn't exist
            varrow<-varrow[,varrow!=""]
        #b) Create data table of all years and var_names
            df<-data.frame(Year=substring(names(varrow),2),
                           Name=as.character(unlist(varrow)))
            df$Name<-as.character(df$Name)
            df$Year<-as.numeric(as.character(df$Year))
        #c) Return first row/cell depending on input
            if(var_names==TRUE){
              return(df)
            }
            return(df[,1])
}
  