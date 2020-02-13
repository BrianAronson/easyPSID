#' Create subset of common family file variables in long format
#' @description Creates an extract dataset in long format consisting of the 500 most frequently reoccurring PSID Family Variables across all supplied waves of the PSID.
#' @param in_direc Directory containing waves of the Family Files in .rds format
#' @param out_direc Directory to place export file into
#' @param num_vars Number of variables to include in export dataset (default = 500). High variable counts with many waves of data require a significant amount of RAM, and may cause this function to throw errors if a computer's RAM is insufficient
#' @param all_years Select most common variables based on all years of the PSID rather than based in the data actually supplied
#' @keywords PSID
#' @export
#' @examples 
#' create_extract(
#'     in_direc=system.file("extdata","rds_dir", package = "easyPSID"),
#'     out_direc=tempdir(),
#'     num_vars=25,
#' )

create_extract<-function(in_direc, out_direc, num_vars=500, all_years=F){
    #1) Assign directories
        # in_direc<-ifelse(is.null(in_direc),getwd(),in_direc)
        # out_direc<-ifelse(is.null(out_direc),getwd(),out_direc)
        filenames<-list.files(path=in_direc,pattern= c("^FAM.*\\.rds$" ),full.names = T)
        filenames2<-list.files(path=in_direc,pattern= c("^FAM.*\\.rds$" ))
    #1.5) Error check
        #Don't run if only one year provided
            if(length(filenames)<2){
                filenames<-paste("Less than two waves of data found in in_direc. Two or more waves of data required")
                stop(message)
            }
    #2) Determine variable names
        #a) determine years of supplied data
            data_years<-gsub('\\D+','',filenames2)
        #b) pull psid info
            tdf<-data$psid_fam
        #c) only include matching years
            if(all_years==F){
                names(tdf)<-gsub('\\D+','',names(tdf))
                tdf<-tdf[,names(tdf) %in% data_years]
            }
        #d) find most common variables
            if(ncol(as.data.frame(tdf))>1){
                var_freq<-apply(tdf,1,function(x) sum(x!=""))
            }else{
                var_freq<-sum(tdf[,1]!="")
            }
            var_rank<-rank(var_freq,ties.method="first")
            var_rank<-max(var_rank)-var_rank
            var_common<-tdf[var_rank<=num_vars,]
            var_names<-as.vector(apply(var_common,1,function(x) x[x!=""][1]))
            
    #3) Redundant steps to make remainder of formula work.
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
        saveRDS(PSIDPanel,file=paste(out_direc,"/","PSID Extract.rds",sep = ""))
}
