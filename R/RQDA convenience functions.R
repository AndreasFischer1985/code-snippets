#add/delete codes (freecode-table) or files (source-table) case (cases), category (codecat), etc.
#------------------------------------------------------------------------------------------------

deleteAllCodes<-function(){RQDAQuery("update freecode set status=0");RQDAQuery("update coding set status=0");CleanProject()};

deleteAllFiles<-function(){RQDAQuery("update source set status=0");RQDAQuery("update coding set status=0");CleanProject()};

deleteAllCases<-function(){RQDAQuery("update cases set status=0");RQDAQuery("update caselinkage set status=0");CleanProject()};

deleteAllCodecats<-function(){RQDAQuery("update codecat set status=0");RQDAQuery("update treecode set status=0");CleanProject()};

deleteCode<-function(id=0){RQDAQuery(paste("update freecode set status=0 where id=",id));;CleanProject()}; #deleteCode(0)

deleteFile<-function(id=0){RQDAQuery(paste("update source set status=0 where id=",id));;CleanProject()}; #deleteCode(0)

addCode<-function(name="wisdom"){
		for(i in name){	 
		 nextid=1;if(dim(RQDAQuery("SELECT id FROM freecode WHERE status==1"))[1]>0)         #if there are ids already
		 	nextid <- max(RQDAQuery("SELECT id FROM freecode WHERE status==1"))+1        #select largest id and add 1
		 if(dim(RQDAQuery(paste("select * from freecode where id=",nextid)))[1]==0)          #if code-id does not exist yet	
		 if(dim(RQDAQuery(paste("select * from freecode where name=",shQuote(i))))[1]==0)    #if code-name does not exist yet	
		        RQDAQuery(paste("insert into freecode (name, id, status,date,owner) values(", shQuote(i),",", nextid, ",1,", shQuote(date()), ",'AF')")); #RQDAQuery("select * from freecode")
		}
}

addFile<-function(file,path=pathTexts){
		if(length(file)>0)
		for(i in file){	 
		 name=i;
		 filePath=paste0(path,name)
		 if (!file.exists(filePath)){
			system('CMD /C "ECHO Please select a txt-file from the following popup-menue && PAUSE"', invisible=FALSE, wait=FALSE)
			filePath=file.choose();
		 }
	 	 text=readLines(filePath)
		 text=paste(text,collapse="\n");
		 text <- gsub("\\\"", "", text);	
		 nextid=1;if(dim(RQDAQuery("SELECT id FROM source WHERE status==1"))[1]>0)     	   #if there are ids already
		 	nextid <- max(RQDAQuery("SELECT id FROM source WHERE status==1"))+1        #select largest id and add 1
		 if(dim(RQDAQuery(paste("select * from source where id=",nextid)))[1]==0)          #if code-id does not exist yet	
		 if(dim(RQDAQuery(paste("select * from source where name=",shQuote(name))))[1]==0) #if code-name does not exist yet	
		        RQDAQuery(paste("insert into source (name, id, file,status,date,owner) values(", 
			shQuote(name),",", 
			nextid, ",",
			"\"",text,"\"",",1,", 
			shQuote(date()), 
			",'AF')"));
		}
}	

addStringAsFile<-function(files="hallo welt"){
		if(length(files)>0)
		for(i in 1:length(files)){	 
		 name=paste("String",i);
	 	 text=files[i];
		 text <- gsub("\\\"", "", text);	
		 nextid=1;if(dim(RQDAQuery("SELECT id FROM source WHERE status==1"))[1]>0)     	   #if there are ids already
		 	nextid <- max(RQDAQuery("SELECT id FROM source WHERE status==1"))+1        #select largest id and add 1
		 if(dim(RQDAQuery(paste("select * from source where id=",nextid)))[1]==0)          #if code-id does not exist yet	
		 if(dim(RQDAQuery(paste("select * from source where name=",shQuote(name))))[1]==0) #if code-name does not exist yet	
		        RQDAQuery(paste("insert into source (name, id, file,status,date,owner) values(", 
			shQuote(name),",", 
			nextid, ",",
			"\"",text,"\"",",1,", 
			shQuote(date()), 
			",'AF')"));
		}
}	
	
addCase<-function(name="AF_Case"){
		for(i in name){	 
		 nextid=1;if(dim(RQDAQuery("SELECT id FROM cases WHERE status==1"))[1]>0)         #if there are ids already
		 	nextid <- max(RQDAQuery("SELECT id FROM cases WHERE status==1"))+1        #select largest id and add 1
		 if(dim(RQDAQuery(paste("select * from cases where id=",nextid)))[1]==0)          #if code-id does not exist yet	
		 if(dim(RQDAQuery(paste("select * from cases where name=",shQuote(i))))[1]==0)    #if code-name does not exist yet	
		        RQDAQuery(paste("insert into cases (name, id, status,date,owner) 							 
			values(", shQuote(i),",", nextid, ",1,", shQuote(date()), ",'AF')"));
		}
}
	
addCodeCat<-function(name="AF_Cat"){
		for(i in name){	 
		 nextid=1;if(dim(RQDAQuery("SELECT catid FROM codecat WHERE status==1"))[1]>0)      #if there are ids already
		 	nextid <- max(RQDAQuery("SELECT catid FROM codecat WHERE status==1"))+1     #select largest id and add 1
		 if(dim(RQDAQuery(paste("select * from codecat where catid=",nextid)))[1]==0)       #if code-id does not exist yet	
		 if(dim(RQDAQuery(paste("select * from codecat where name=",shQuote(i))))[1]==0)    #if code-name does not exist yet	
		        RQDAQuery(paste("insert into codecat (name, catid, status,date,owner) 							 
			values(", shQuote(i),",", nextid, ",1,", shQuote(date()), ",'AF')"));
		}
}

addCaseLink<-function(fid=1,caseID=1){
		if(dim(RQDAQuery(paste("select * from caselinkage where fid=",fid)))[1]==0 |
		   dim(RQDAQuery(paste("select * from caselinkage where caseid=",caseID)))[1]==0)  #if the linkage does not exist already
			RQDAQuery(paste("insert into caselinkage (fid, caseid,status,date,owner) 							 
			values(", shQuote(fid),",", shQuote(caseID), ",1,", shQuote(date()), ",'AF')"));		
}

addTreeCode<-function(cid=1,catID=1){
		if(dim(RQDAQuery(paste("select * from treecode where cid=",cid)))[1]==0 |
		   dim(RQDAQuery(paste("select * from treecode where catid=",catID)))[1]==0)  #if the linkage does not exist already
			RQDAQuery(paste("insert into treecode (cid, catid,status,date,owner) 							 
			values(", shQuote(cid),",", shQuote(catID), ",1,", shQuote(date()), ",'AF')"));		
}

recodeCodesAsCode<-function(codes="wahrheit",as="liebe"){
		if(dim(RQDAQuery(paste("select * from source where name=",shQuote(as))))[1]==0) addCode(as); 	#add Code if it does not exist already	
		codingList=RQDAQuery("select * from coding");							
		codings=codingList[codingList["cid"]==which(RQDAQuery("select name from freecode")==codes),]	#extract all codings related to codes "codes", which should be recoded as "as"
		for(i in 1:dim(codings)[1]) {
			coding=codings[i,];
			fid=coding$fid;seltext=coding$seltext;selfirst=coding$selfirst;selend=coding$selend;status=coding$status;owner=coding$owner;date=coding$date;memo=coding$memo;
			if(dim(RQDAQuery(paste("select * from coding where fid=",fid," and cid=",max(1,which(RQDAQuery("select name from freecode")==as)) )))[1]==0) 
			RQDAQuery(paste("insert into coding (cid, fid,seltext,selfirst,selend,status,owner,date,memo) values(", 
			  shQuote(max(1,which(RQDAQuery("select name from freecode")==as))),
			  ",", shQuote(fid),
			  ",", shQuote(seltext),
			  ",", shQuote(selfirst),	
			  ",", shQuote(selend),
			  ",", shQuote(status),
			  ",", shQuote(owner),
			  ",", shQuote(date),
			  ",", shQuote(memo),")"));
		}
}

	
# add codings (segments containing one code or a specific phrase are coded correspondingly or as first code)
#-----------------------------------------------------------------------------------------------------------

codeAutomatically<-function(lowerToo=T){vec1=t(RQDAQuery("select name from freecode"));vec2=t(RQDAQuery("select id from freecode"));for(i in 1:length(vec1)) codingBySearch(paste0("[\\W]",vec1[i],"[\\W]"), fid=getFileIds(),cid=vec2[i],seperator="\n\n");if(lowerToo){for(i in 1:length(vec1)) 	codingBySearch(paste0("[\\W]",tolower(vec1[i]),"[\\W]"), fid=getFileIds(),cid=vec2[i],seperator="\n\n");}}

codeAutomaticallyAllAsOne<-function(lowerToo=T){vec1=t(RQDAQuery("select name from freecode"));for(i in 1:length(vec1)) codingBySearch(paste0("[\\W]",vec1[i],"[\\W]"), fid=getFileIds(),cid=1,seperator="\n\n");if(lowerToo){for(i in 1:length(vec1)) codingBySearch(paste0("[\\W]",tolower(vec1[i]),"[\\W]"), fid=getFileIds(),cid=1,seperator="\n\n");}}

codeAutomaticallyAllAsN<-function(codes="",as="",lowerToo=T){vec1=codes;as=which(RQDAQuery("select name from freecode")==as); for(i in 1:length(vec1)) codingBySearch(paste0("[\\W]",vec1[i],"[\\W]"), fid=getFileIds(),cid=as,seperator="\n\n");if(lowerToo){for(i in 1:length(vec1)) codingBySearch(paste0("[\\W]",tolower(vec1[i]),"[\\W]"), fid=getFileIds(),cid=as,seperator="\n\n");}}

 
# setUpRqda re-creates an existing rqda-Project and specifies files codes, codings, etc.
#---------------------------------------------------------------------------------------

setUpRqda=function(
	project="new.rqda", 
	files=c("Memorabilia.txt","Apology.txt","Gospels.txt","Quran.txt","Analects.txt","TaoTehKing.txt","Dhammapada.txt","Gita.txt"),
	cases=c("Socrates","Socrates","Jesus","Mohammed","Konfuzius","Tao","Buddha","Krishna"),
	codes=c("wisdom"),
	categories=c("wisdom"),
	automateCoding=T,
	pathProject="./wisLit/",
	pathTexts="./wisLit/"
){	
	suppressPackageStartupMessages(if(!require("pacman"))install.packages("pacman"));pacman::p_load(RQDA,gutenbergr);
	projectPath=paste0(pathProject,project);
	if (!file.exists(projectPath)){
		system('CMD /C "ECHO Please select a RQDA-Project from the following popup-menue && PAUSE"', invisible=FALSE, wait=FALSE)
		projectPath=file.choose();
	}

	# re-create a project according to specifications
	#------------------------------------------------
	closeProject(updateGUI=T);
	openProject(projectPath,updateGUI=T);					
	deleteAllFiles();
	deleteAllCodes();
	deleteAllCases();
	deleteAllCodecats();
	addCode(codes);
	addFile(files);
	addCase(cases);
	addCodeCat(categories);
	addCaseLink();
	addTreeCode();
	addGutenbergFile(gutenbergIDs);
	codeAutomatically();
	closeProject(updateGUI=T);
	openProject(projectPath,updateGUI=T)
	RQDAQuery("select name from source");
	RQDAQuery("select name from freecode");
}


# exportRqda exports all tables of an RQDA-project to an excel-file with one sheet per table
#-------------------------------------------------------------------------------------------

exportRqda<-function(saveto="rqda.excelfile.xlsx"){
	suppressPackageStartupMessages(if(!require("pacman"))install.packages("pacman"));pacman::p_load(xlsx);
	wb <- createWorkbook()
	sh0 <- createSheet(wb=wb, sheetName="project")
	sh1 <- createSheet(wb=wb, sheetName="source")
	sh2 <- createSheet(wb=wb, sheetName="freecode")
	sh3 <- createSheet(wb=wb, sheetName="coding")
	sh4 <- createSheet(wb=wb, sheetName="codecat")
	sh5 <- createSheet(wb=wb, sheetName="treecode")
	sh6 <- createSheet(wb=wb, sheetName="treefile")
	sh7 <- createSheet(wb=wb, sheetName="cases")
	sh8 <- createSheet(wb=wb, sheetName="caselinkage")
	sh9 <- createSheet(wb=wb, sheetName="annotation")
	sh10 <- createSheet(wb=wb, sheetName="attributes")
	sh11 <- createSheet(wb=wb, sheetName="fileAttr")
	sh12 <- createSheet(wb=wb, sheetName="filecat")
	sh13 <- createSheet(wb=wb, sheetName="image")
	sh14 <- createSheet(wb=wb, sheetName="imageCoding")
	sh15 <- createSheet(wb=wb, sheetName="journal")
	addDataFrame(x=RQDAQuery("select * from project"), sheet=sh0)
	addDataFrame(x=RQDAQuery("select * from source"), sheet=sh1)
	addDataFrame(x=RQDAQuery("select * from freecode"), sheet=sh2)
	addDataFrame(x=RQDAQuery("select * from coding"), sheet=sh3)
	addDataFrame(x=RQDAQuery("select * from codecat"), sheet=sh4)
	addDataFrame(x=RQDAQuery("select * from treecode"), sheet=sh5)
	addDataFrame(x=RQDAQuery("select * from treefile"), sheet=sh6)
	addDataFrame(x=RQDAQuery("select * from cases"), sheet=sh7)
	addDataFrame(x=RQDAQuery("select * from caselinkage"), sheet=sh8)
	addDataFrame(x=RQDAQuery("select * from annotation"), sheet=sh9)
	addDataFrame(x=RQDAQuery("select * from attributes"), sheet=sh10)
	addDataFrame(x=RQDAQuery("select * from fileAttr"), sheet=sh11)
	addDataFrame(x=RQDAQuery("select * from fileCat"), sheet=sh12)
	addDataFrame(x=RQDAQuery("select * from image"), sheet=sh13)
	addDataFrame(x=RQDAQuery("select * from imageCoding"), sheet=sh14)
	addDataFrame(x=RQDAQuery("select * from journal"), sheet=sh15)
	saveWorkbook(wb, saveto)
}

