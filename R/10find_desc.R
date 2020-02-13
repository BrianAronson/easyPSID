#' Find description of PSID variable
#' @description Finds the descriptions of selected PSID variables.
#' @param variables Variable names to look up (as individual string or vector of strings)
#' @keywords PSID
#' @export
#' @examples find_description(variables=c("V2","V30"))

find_description<-function(variables){
    #1) Make sure variable is in character format
        variables<-as.character(variables)
    #2) Find variables in reference dataset
        varrow<-data$psid_desc[match(variables,data$psid_desc[,1]),]
    #3) If variables is not in reference dataset, just show the variables name
        if(all(is.na(varrow))){
          return(variables)
        }
    #4) Otherwise, print variables name and description
        return(varrow)
}
  


                 