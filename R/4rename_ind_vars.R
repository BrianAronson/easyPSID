#' Renames longitudinal Cross-year Individual variables and saves in long format
#' @description Renames all repeated variables in the Cross-year Individual file so that matching variables across waves have the same name, and transforms the resulting dataset into long format. The longitudinal file does not include rows for respondents who were missing in a given wave, and cross-sectional variables are marked as NA during waves when they were not asked. In addition, the resulting file adds two variables for ease of use: "Year" and "fam_id_68". 
#' 
#' This function may require up to 8gb of RAM, and will likely throw "cannot allocate memory" errors to users with less RAM on their computer. Users with memory issues should implement the "only_long_vars" or "cust_vars" options.
#'
#' @param in_direc Directory of PSID Cross-year Individual file .rds file
#' @param out_direc Directory for renamed and transformed PSID Cross-year Individual file to be saved to
#' @param only_long_vars Keep only longitudinal variables in dataset
#' @param cust_vars Custom variables to keep in dataset (as character vector). Output will always include "ER30001", "fam_id_68", and "Year"
#' @keywords PSID
#' @export
#' @examples 
#' rename_ind_vars(
#'    only_long_vars=TRUE, 
#'    in_direc=system.file("extdata","rds_dir", package = "easyPSID"),
#'    out_direc=tempdir()
#' )

rename_ind_vars<-function(in_direc,out_direc,only_long_vars=F,cust_vars=NULL){
    #1) Deprecated - Set directory
        # in_direc<-ifelse(is.null(in_direc),getwd(),in_direc)
        # out_direc<-ifelse(is.null(out_direc),getwd(),out_direc)
    #2) Load rds file
        temp_file<-list.files(path=in_direc,pattern= c("IND.*\\.rds$" ),full.names=T)[1]
        temp_file2<-list.files(path=in_direc,pattern= c("IND.*\\.rds$" ))[1]
        df<-readRDS(temp_file)
    #3) Identify dimensions of eventual dataframe
        ncols<-dim(data$psid_ind)[1]
        nyears<-dim(data$psid_ind)[2]
        ninds<-nrow(df)
        nrows<-nyears*ninds
    #4) Create transposed version of data$psid_ind, sorted by time first in dataset
        early_name<-apply(data$psid_ind,1,function(x) x[x!=""][1])
        index<-data$psid_ind[order(early_name),]
        index<-t(index)
    #5) For convenience, create a column in data that is all NAs
        df$colna<-NA
    #6) Identify whether variable is cross-sectional
        cross<-apply(index,2, function(x) length(x[x!=""]))
        cross<-ifelse(cross==1,1,0)
    #7) Identify whether observation was not present during a given wave
        #ER30003 indicates whether non-response in given wave
            ER30003<-which(index=="ER30003",arr.ind = T)[2]
            #i) Find corresponding variable names
                varnames<-as.vector(index[,ER30003])
            #ii) Replace missing variable names with colna
                varnames[varnames==""]<-"colna"
            #iii) Pull out those column names and convert to vector
                resp<-vector()
                for(j in 1:length(varnames)){
                  resp<-c(resp,df[,varnames[j]])
                }
            #iv) Remove missing individuals
                resp[resp>0]<-1
    #8) Subset to custom variables or longitudinal variables
        if(!is.null(cust_vars)){
          if(!"ER30001" %in% cust_vars){
            cust_vars<-c(cust_vars,"ER30001")
          }
          indcols<-sapply(cust_vars,function(x) which(index == x,arr.ind = T)[2])
          index<-index[,indcols]  
        }else if(only_long_vars==T){
          index<-index[,cross==0]
        }
    #9) For each unique variable in individual file, convert to long format
        #i) Find corresponding variable names across waves
            ind_longdf<-lapply(as.data.frame(index),as.vector)
        #ii) Replace missing variable names with colna
            ind_longdf<-lapply(ind_longdf,function(x) ifelse(x=="","colna",x))
        #iii) Pull out those columns
            ind_longdf<-lapply(ind_longdf,function(x) df[,x])
        #iv) Convert columns to single vector
            fastunlist<-function(x){
              x<-c(as.matrix(x))
              x<-x[resp==1] #(not usually part of function)
            }
            percent <- function(x, digits = 0, format = "f", ...) {
              paste0(formatC(100 * x, format = format, digits = digits, ...), "%")
            }
            for(i in 1:length(ind_longdf)){
              ind_longdf[[i]]<-fastunlist(ind_longdf[[i]])
              if(i/10==floor(i/10)){
                gc()
                message(percent(i/length(ind_longdf)))
              }
            }
            gc()
        #v) Convert list to dataframe
            ind_longdf<-do.call(cbind,ind_longdf)
            gc()
            ind_longdf<-as.data.frame(ind_longdf)
            gc()
    #10) Add metadata to dataframe
        #a) Create proper names for columns
            if(!is.null(cust_vars)){
              early_name2<-cust_vars
            }else if(only_long_vars==T){
              early_name2<-apply(index,2,function(x) x[x!=""][1])
            }else{
              early_name2<-early_name[order(early_name)]  
            }
            names(ind_longdf)<-early_name2
        #b) Bring back variable descriptions
            temp<-find_description(names(ind_longdf))
            attr(ind_longdf,"var.labels")<-temp$Description
        #c) Add a year variable
            uyears<-gsub('\\D+','', row.names(index))
            Year<-rep(uyears,each=ninds)
            Year<-Year[resp==1]
            ind_longdf$Year<-Year
        #d) Add a family id variable
            fam_id_68<-ind_longdf$ER30001
      #11) Save file
          dir.create(out_direc,showWarnings = F)
          temp_file2<-gsub(".rds","",temp_file2)
          saveRDS(ind_longdf,file=paste(out_direc,"/",temp_file2," - Long Format.rds",sep=""))
          message(percent(1))
}





