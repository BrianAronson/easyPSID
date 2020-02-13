#' Convert all PSID files from .txt format to .rds format
#' @description Converts all PSID fixed width format .txt files in a selected directory into .rds format. Importantly, this function assumes that all files contained in the original PSID .zip files (especially those ending in .do) are present in the same directory as the PSID .txt files, and that all files within that directory have the same names as when first unzipped.
#' @param in_direc Directory containing unzipped PSID .txt and .do files
#' @param out_direc Directory to place PSID .rds files into
#' @keywords PSID
#' @export
#' @importFrom stringr str_extract str_extract_all
#' @importFrom LaF laf_open_fwf
#' @examples
#' convert_to_rds(
#'     in_direc=system.file("extdata","unzip_dir", package = "easyPSID"),
#'     out_direc=tempdir()
#' )

convert_to_rds<-function(in_direc,out_direc){
    #1 - Deprecated - Specify directory
        # in_direc<-ifelse(is.null(in_direc),getwd(),in_direc)
        # out_direc<-ifelse(is.null(out_direc),getwd(),out_direc)
    #2 - Read do and txt files
        do_files<-c(list.files(path=in_direc,pattern= c("*\\.do$" ),full.names=T))
        txt_files<-c(list.files(path=in_direc,pattern= c("*\\.txt$" ),full.names=T))
        txt_files2<-c(list.files(path=in_direc,pattern= c("*\\.txt$" )))
    #3 - Convert Stata .do files to R syntax
      for(i in 1:length(do_files)){
          #a) Read stata code
              stata_code <- readLines(do_files[i])
          #b) Keep relevant lines
              code_start <- min(grep('infix', stata_code))
              code_end <- min(grep('using', stata_code))-1
              stata_keep <- stata_code[code_start:code_end]
              stata_keep<-stata_keep[-1] #(just contains "infix")
          #c) Extract all variable names
              variable_names <- unlist(str_extract_all(stata_keep, '[A-Z][a-zA-Z0-9_]+'))
          #d) Extract all variable labels
              #i) Find where relevant code starts
                  labs_start <- min(grep('label', stata_code))
                  labs_end <- max(grep('label', stata_code))
                  stata_labs <- stata_code[labs_start:labs_end]
              #ii) Grab strings between quotes
                  var_descriptions<-vector(length=length(stata_labs))
                  for(j in 1:length(var_descriptions)){
                      temp<-str_extract_all(stata_labs[j],"\"(.+)\"")[[1]]
                      #Remove quotes
                          var_descriptions[j]<-gsub("\"","",temp)
                      #Remove extra spaces
                          var_descriptions[j]<-gsub("  ","",var_descriptions[j])
                  }
          #iii) Extract all column indices
              temp_columns<-unlist(str_extract_all(stata_keep,'[0-9]+ [/-] [0-9]+'))
          #iv) Change column ranges to column counts
              columns<-vector()
              for(j in 1:length(temp_columns)){
                  a<-temp_columns[j]
                  b<-as.numeric(unlist(str_extract_all(a,'[0-9]+')))
                  columns[j]<-b[2]-b[1]+1
              }
    #4) Use converted stata code to read in txt files and use stata variable labels
          temp_data <- laf_open_fwf(txt_files[i], column_widths = columns,column_types = rep("double",length(columns)))
          temp_data <- temp_data[,]
          names(temp_data) <- variable_names
          attr(temp_data,"var.labels")<-var_descriptions
    #5) Save files as "[Type] [Year].rds"
        #a) Determine file name
            temp_year<-str_extract(txt_files2[i],'[0-9]+')
            temp_heading<-substr(txt_files2[i],1,3)
            temp_name<-paste(temp_heading,temp_year,".rds",sep="")
        #b) Save file
            dir.create(out_direc,showWarnings = F)
            saveRDS(object=temp_data,file=paste(out_direc,"/",temp_name,sep = ""))
        #c) Notify user of progress
            message(paste(temp_name,"Converted"))
      }
}

