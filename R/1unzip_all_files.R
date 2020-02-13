#' Unzip all PSID files
#' @description Unzips all .zip_files files in the specified directory.
#' @param in_direc Directory of .zip files to be unzipped
#' @param out_direc Directory for unzipped PSID files to be placed
#' @keywords PSID
#' @export
#' @importFrom utils object.size unzip
#' @examples
#' unzip_all_files(
#'     in_direc=system.file("extdata", "zip_dir", package = "easyPSID"),
#'     out_direc=tempdir()
#' )

unzip_all_files<-function(in_direc,out_direc){
    #1) Deprecated - Set directories to current directory if none supplied
        # in_direc<-ifelse(is.null(in_direc),getwd(),in_direc)
        # out_direc<-ifelse(is.null(out_direc),in_direc,out_direc)
    #2) Find all zip_files files in folder
        zip_files<-list.files(path=in_direc,pattern= c("*\\.zip$" ),full.names=T)
    #3) Unzip_files files to specified directories
        dir.create(out_direc,showWarnings = F)
        for(i in 1:length(zip_files)){
          unzip(zip_files[i],exdir=out_direc)
        }
    #4) Indicate that files are unzip_filesped
        message("Files Unzipped")
}
