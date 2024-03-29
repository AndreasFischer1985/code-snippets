##########################################################################
# Simple German-speaking Eliza-Chatbot (pre-Alpha stage of development)
##########################################################################

chatBot=function(brain=NULL,data=data.frame(x=c(1,2,3),y=c(2,2,3))){
	exit=F;focus=list();
	inp=character(0);out="";
	matchAll<-function(string=NA,pattern=".*",value=T,...){
		y=gregexpr(pattern,string,...)
		l=(lapply(y,function(x)rbind(x,attr(x,"match.length"))))
		if(value==F) return(lapply(l,t)) else
		t=lapply(1:length(l),function(i){l1=l[[i]];cbind(apply(l1,2,function(x1)if(x1[2]>-1)return(substr(string[[i]],x1[1],x1[1]+x1[2]-1)) else return(matrix(NA,ncol=0,nrow=0))))})
		return(t)
	}
	matchOne<-function(string=NA,pattern=".*",value=T,...){
		y=regexpr(pattern,string,...)
		z=y + attr(y, "match.length")-1;
		#z[attr(y, "match.length")==-1]=NA
		l=cbind(y,z)
		t=t(t(substr(string, y, z)))
		if(value==F) return(l) else return(t)
	}
	matches=function(x,inp){length(grep(paste0("\\b",x,"\\b"),inp))>0}
	star=function(x,inp){exchangeTerms(sub(paste0(".*\\b",x,"\\b"),"",inp))}
	exchangeTerms=function(x){
		l=cbind(c("ich","meiner","meine","meines","meins","mir","mich","bin","war","kann","will","darf","muss","soll"),c("du","deiner","deine","deines","deins","dir","dich","bist","warst","kannst","willst","darfst","musst","sollst"));l=rbind(l,cbind(l[,2],l[,1]));
		sub2=function(p,y,x){x0=x;for(i in 1:length(p)){x=gsub(p[i],y[i],x0);if(x!=x0)return(x);};return(x);}
		br=F;i=1;while(br==F){
			x2=substr(x,i,nchar(x))
			x3=sub2(paste0("^",l[,1],"\\b"),l[,2],x2);
			ch=any(substr(x,i-1,i-1)==""|grepl("[ .,;?!\\(\\)]",substr(x,i-1,i-1)))
			if(ch) x=paste0(substr(x,1,i-1),x3);
			if(nchar(x)==i)br=T;i=i+1;}
		return(x)
	}
	consider=function(inp,out2,inp2){
		if(!is.na(inp2))if(nchar(inp2)>0)message(paste0("User:\n",inp2,"\n"))
		if(!is.na(out2))if(nchar(out2)>0)message(paste0("Bot:\n",out2,"\n"))		
		if(!is.na(inp))if(nchar(inp)>0)message(paste0("User:\n",inp,"\n"))

		# Internal preprocessing:
		inp0=inp;
		inp=gsub("[,;]","",tolower(inp))

		# Sonderfunktionen:
		if(length(inp)==0|is.na(inp)){if(is.null(brain)) return("Kannst du mir sagen, wo ich meinen Kopf gelassen habe?") else return("Herzlich willkommen, was kann ich für dich tun?")} else
		if(matches("^Kannst du mir sagen, wo ich meinen Kopf gelassen habe[?]$",out2)) {
			if(file.exists(inp)) return("[Brain-Datei laden]")
			if(matches("^[Nn]ein",inp))  return("Okay, dann arbeite ich weiter im Default-Modus.") 
		}
		x="([Pp]fad|[Aa]arbeitsverzeichnis|setwd) [^ ]+";if(matches(x,inp)) {
			try({
				setwd(sub(".*([Pp]fad|[Aa]arbeitsverzeichnis|setwd) ","",inp0));
				return(paste0("[Pfad angepasst: ",sub(".*[Pp]fad ","",inp0),"]"))
			   })
			return(paste0("Ich konnte den Pfad ",sub(".*([Pp]fad|[Aa]arbeitsverzeichnis|setwd) ","",inp0),"nicht aufrufen"))
		}

		# Reaktionen auf Aufforderungen:
		x="(^[Uu]hrzeit$|[Ww]ie spät ist es|wie spät es ist)";if(matches(x,inp)) return(paste0("Wir haben jetzt ",Sys.time()))
		x="(^[Ww]etter|^[Ww]etterbericht)";if(matches(x,inp)) return(paste0("[Wetter berichten]"))
		x="(^[Hh]umor|Erzähl einen Witz)";if(matches(x,inp)){
			html=paste(readLines("https://www.aberwitzig.com/"), collapse = "\n")
			return(gsub("(<.*?>|&nbsp;|&quot;|\n|\t)","",gsub("(.*\t2[.]|\t3[.].*)","",html)))
		}
		x="(^[Ss]tatus|^[Ss]atusreport)";if(matches(x,inp)) return(paste0("[Statusreport]"))
		x="(^[Mm]usik|^[Ss]piel[e]? [Mm]usik|^[Ss]piel[e]? mp3)";if(matches(x,inp)) {
			list=list.files(pattern=".mp3")
			if(length(list)>0)try({lapply(list,function(x)shell(x,wait=FALSE));return(paste0("[",paste(list,collapse=",")," abgespielt]"))})
			if(length(list)==0)return(paste0("Ich konnte keine mp3-Dateien in ",getwd()," finden"))
			return(paste0("Ich konnte keine mp3-Dateien in ",getwd()," abspielen"))
		}
		x="(^[Vv]ideo[s]?|^[Ss]spiel [Mm]Video[s]?) ";if(matches(x,inp)){
			return(paste0("[Video abspielen]"))
		}
		x="^([Öö]ffne|[Bb]rowse) ";if(matches(x,inp)){
			tryCatch(
			{path=sub("^([Öö]ffne|[Bb]rowse) ","",inp0); if(grepl("(http|www[.])",path)[1]==F) path=paste0("www.",path); browseURL(path);return(paste0("[Web-Browser gestartet]"));},
 			error=function(cond) {
				try({shell(sub("^([Öö]ffne|[Bb]rowse) ","",inp0), wait=FALSE);return(paste0("[File-Browser gestartet]"));})
				return(paste0("Ich konnte ",sub("^([Öö]ffne|[Bb]rowse) ","",inp0)," nicht öffnen"))
			}
			)
			return(paste0("Ich konnte die Website ",sub("^([Öö]ffne|[Bb]rowse) ","",inp0)," nicht öffnen"))
		}
		x="^([Zz]eige|[Pp]lotte) ";if(matches(x,inp)){ 
			if(matches("[0-9]+",inp)) {
				plotted=F;
				indices=as.numeric(unlist(matchAll(inp,"[0-9]+",value=T)));print(indices)
				if(length(indices)==1 & indices[1]>0 & indices[1]<=dim(data)[2]) { hist(data[,indices[1]],xlab=indices[1],main="Histogram");plotted=T} else 
				if(length(indices)==2 & indices[1]>0 & indices[2]>0 & indices[1]<=dim(data)[2] & indices[2]<=dim(data)[2]) { plot(data[,indices[1]],data[,indices[2]],xlab=indices[1],ylab=indices[2]); plotted=T} 
				if(length(indices)>2) return("Plots von mehr als 2 Variablen überfordern mich aktuell leider noch.")	
				if(plotted==T)return(paste0("Daten mit Index ",paste(indices,collapse=",")," geplottet."))
				if(plotted==F)return(paste0("Daten mit Index ",paste(indices,collapse=",")," konnte ich nicht plotten."))
			}
		}
		# Spezifische Reaktionen auf Antworten:
		if(matches("(^[Jj]a)",inp)){
			if(matches("Willst du eine Google-Suche",out2)) return("[Google Suche starten]")
			return("Okay.")	
		} else
		if(matches("^[Nn]ein",inp))return("Okay, dann nicht.")

		#Allgemeine Reaktionen auf Antworten (Wichtiges vorher platzieren)
		if(matches("^Warum glaubst du denn ",out2)) return("Ach so.") 
		
		# Allgemeine Reaktionen auf Fragen:
		x="([Ww]er ist |[Ww]as ist |[Ee]rzähl mir von )";if(matches(x,inp)) return(paste0("Willst du eine Google-Suche nach ",star(x,inp)," starten?"))
		x="([Ww]er hat )";if(matches(x,inp)) return(paste0("Willst du eine Google-Suche danach starten, wer ",star(x,inp)," hat?"))
		x="([Ww]arum|[Ww]eshalb|[Ww]wozu|[Ww]weswegen)";if(matches(x,inp)) return(paste0("Ich kenne den Grund leider auch nicht."))
		x="([Ww]ie|[Ww]oher|[Gg]ibt es|[?])";if(matches(x,inp)) return(paste0("Das weiß ich leider auch nicht."))
		x="([Kk]annst du|[Hh]ast du)";if(matches(x,inp)) return(paste0("Das weiß ich leider auch nicht."))
		x="([Ww]ürdest|[Mm]öchtest|[Ww]illst|[Ww]irst) du";if(matches(x,inp)) return(paste0("Ich bin mir nicht sicher, ob ich das wünschenswert finde."))

		# Allgemeine Reaktionen auf Aussagen:
		x="[Ii]ch bin ";if(matches(x,inp)) return(paste0("Warum glaubst du denn ",star(x,inp)," zu sein?"))
		x="[Ii]ch (denke|glaube|meine) ([Aa]ber )?";if(matches(x,inp)) return(paste0("Warum glaubst du denn ",star(x,inp),"?"))
		x="[Ii]ch (kann) ([Aa]ber )?";if(matches(x,inp)) return(paste0("Warum kannst du ",star(x,inp),"?"))
		x="[Ii]ch (habe) ([Aa]ber )?";if(matches(x,inp)) return(paste0("Warum hast du denn ",star(x,inp),"?"))
		x="[Ii]ch (würde) ([Aa]ber )?";if(matches(x,inp)) return(paste0("Warum würdest du denn ",star(x,inp),"?"))
		x="[Ww](eil|egen)";if(matches(x,inp)) return(paste0("Ach deswegen."))
		x="([Aa]ber )?[Dd]as ist( aber)?";if(matches(x,inp)) return(paste0("Ja, ich denke auch das ist",star(x,inp)))

		x="([Hh]i|[Hh]allo|[Hh]ello)";if(matches(x,inp)) return(paste0("Hallo."))
		x="([Nn]icht gut)";if(matches(x,inp)) return(paste0("Das ist nicht gut."))
		x="([Nn]icht schlecht)";if(matches(x,inp)) return(paste0("Das ist gut."))
		x="([Ss]chlecht)";if(matches(x,inp)) return(paste0("Das ist nicht gut."))
		x="([Gg]ut)";if(matches(x,inp)) return(paste0("Das ist gut."))

		# Default-Antwort:			
		return("Das kann man wohl sagen.")
	}
	while(!exit){
		out=c(consider(inp[1],out[1],inp[2]),out)[1:10]
		if(nchar(out[1])>0)message(paste0("Bot:\n",out[1],"\n"))
		inp=c(as.character(readline(prompt="User:")),inp)[1:10];		
		if(length(grep("^[Ee]xit$",inp[1]))==1) exit=T
	}	
}

chatBot()
