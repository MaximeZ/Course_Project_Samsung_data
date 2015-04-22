run_analysis <- function(){
  
  wdir=getwd()
  wdir=paste(wdir,"UCI HAR Dataset",sep="/")
  if (!file.exists(wdir))
    stop('The Samsung data is not in the working directory')
  else {
    library(data.table)
    # reading names of variables and selecting those corresponding to mean and standard deviation
    # transforming the names  into a readable format
    # finding numbers of columns of mean and std variables to select them further from numeric tables
    al<-read.table(paste(wdir,"activity_labels.txt",sep="/"))
    al<-as.character(al[,2])  
    VarNames<-read.table(paste(wdir,"features.txt",sep="/"))
    VarNames<-as.character(VarNames[,2])
    ColNumbers<-grep("mean()[^A-Za-z]|std()[^A-Za-z]",VarNames)
    VarNames<-grep("mean()[^A-Za-z]|std()[^A-Za-z]",VarNames,value=TRUE)
    VarNames<-sapply(strsplit(VarNames,"-"),function(x) paste((ifelse(grepl("mean",x[2])==TRUE,"MeanOf","StDivOf")),substr(x[1],2,nchar(x[1])),ifelse(length(x)==2,"",paste("AlongDim",x[3],sep="")),ifelse(substr(x[1],1,1)=="f","InFreqDomain","InTimeDomain"),sep=""))                
    VarNames<-c("Subject","Activity",VarNames)
   
    #Train sample
    #reading measuremnt data, numbers of subjects and numbers corresponding to activities
    #transforming activities from numeric to descriptive text format
    #binding resulting tables into the single one
    x_train<-read.table(paste(wdir,"train/X_train.txt",sep="/"))
    x_train<-x_train[,ColNumbers]
    y_train<-read.table(paste(wdir,"train/y_train.txt",sep="/"))
    y_train<-sapply(y_train,function(x) al[x])
    subject_train<-read.table(paste(wdir,"train/subject_train.txt",sep="/"))
    all_train<-cbind(subject_train,y_train,x_train)
   
    #Test sample
    #reading measuremnt data, numbers of subjects and numbers corresponding to activities
    #transforming activities from numeric to descriptive text format
    #binding resulting tables into the single one
    x_test<-read.table(paste(wdir,"test/X_test.txt",sep="/"))
    x_test<-x_test[,ColNumbers]
    y_test<-read.table(paste(wdir,"test/y_test.txt",sep="/"))
    y_test<-sapply(y_test,function(x) al[x])
    subject_test<-read.table(paste(wdir,"test/subject_test.txt",sep="/"))
    all_test<-cbind(subject_test,y_test,x_test)
  
    #Combining test and train samples
    all_test_train<-rbind(all_test,all_train)
    names(all_test_train)<-VarNames
    
    #Grouping data by Subject and Activity and computing averages for each subject-activity pair
    dtF<-data.table(all_test_train)
    dtF<-dtF[,lapply(.SD,mean),by=list(Subject,Activity)]
    dtF<-dtF[order(dtF$Subject),]
    #Writing data into text file
    write.table(dtF,"Samsung_data.txt",sep=" ",row.names=FALSE,col.names=TRUE)
    
  }
}