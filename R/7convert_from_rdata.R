#' Export PSID files to another statistical language
#' @description Exports all .rds files in the chosen directory into a common file format used by one of three other statistical programming languages (SPSS, SAS, and STATA). Unlike most alternatives, this function retains all variable labels provided by the PSID.
#' @param language Language to export PSID .rds files into (options include SPSS, SAS, and STATA)
#' @param in_direc Directory of PSID .rds files to export. Note that large files can take a long time to export.
#' @param out_direc Directory for exported files to be placed
#' @keywords PSID
#' @export 
#' @importFrom foreign write.dta write.foreign
#' @examples 
#' convert_from_rds(
#'     language="STATA", 
#'     in_direc=system.file("extdata","rds_dir", package = "easyPSID"),
#'     out_direc=tempdir()
#' )

convert_from_rds<-function(language, in_direc, out_direc){
    #1) Prepare directories and file names
        # in_direc<-ifelse(is.null(in_direc),getwd(),in_direc)
        # out_direc<-ifelse(is.null(out_direc),in_direc,out_direc)
        dir.create(out_direc,showWarnings = F)
        filenames<-list.files(path=in_direc,pattern= c(".*\\.rds$" )) #only files ending with ".rds"
    #2) Export data
      for(i in 1:length(filenames)){  
        tempdataframename<-readRDS(paste(in_direc,"/",filenames[i],sep=""))
        if(language=="SPSS"){
          write.foreign(tempdataframename, paste(out_direc,"/",filenames[i],".txt",sep=""), paste(out_direc,"/",tempdataframename,".sps",sep=""),   package="SPSS")
          }
        if(language=="SAS"){
          write.foreign(tempdataframename, paste(out_direc,"/",filenames[i],".csv",sep=""), paste(out_direc,"/",tempdataframename,".sas",sep=""), dataname=gsub(" ","",tempdataframename),  package="SAS")
          }
        if(language=="STATA"){
          write.dta(tempdataframename,  paste(out_direc,"/",filenames[i],".dta",sep=""))
          }
        message(paste(filenames[i],"Exported"))
      }
}

