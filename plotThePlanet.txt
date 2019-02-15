plotThePlanet=function(
	targetname=NULL,
	newlabel=NULL,
	colors=NULL,
	context=.01,
	label.id="NAME_EN",
	url="https://github.com/nvkelso/natural-earth-vector/raw/master/50m_cultural/",
	files=c(
		"ne_50m_admin_0_countries.shp",
		"ne_50m_admin_0_countries.shx",
		"ne_50m_admin_0_countries.cpg",
		"ne_50m_admin_0_countries.dbf",
		"ne_50m_admin_0_countries.prj"),
	cex=1,
	suppress.labels=F,
	bg=rgb(0,0,1,.2),
	...
){


	library(stringr)

	# Download and unzip zip-file if necessary
	if(length(grep("[.]zip$",url))>0){
		if(!file.exists("plotThePlanetMap.zip"))download.file(url,"plotThePlanetMap.zip");
		unzip("plotThePlanetMap.zip");
	}

	# Download data and metadata (i.e. the "files") if necessary:
	for(file in files)if(!file.exists(file))download.file(paste0(url,file),file,mode = "wb")

	# Prepare data for plotting:
	object=sf::st_read(grep("shp",files,value=T))
	map=object$geometry

	get_coord=function(target){
		output=capture.output(print(target)[[1]])[4];
		bbox=suppressWarnings(as.numeric(unlist(str_split(output," "))));
		xlim=c(bbox[13],bbox[17])
		ylim=c(bbox[15],bbox[19])
		res=list(xlim=xlim,ylim=ylim)
		return(res)
	}


	# Specify target area and its color:
	colorsnull=F
	if(is.null(colors)){colors=rep("white",length(map));colorsnull=T}
	if(!colorsnull&length(colors)>1&length(colors)<length(map)&length(colors)==length(targetname)){
		colors2=rep("white",length(map));
		for(i in 1:length(targetname))
			colors2[object[[label.id]]==targetname[i]]=colors[i];
		colors=colors2;}
		
	if(!is.null(targetname)){
		li=list()
		for(i in 1:length(targetname)){	
			target=map[object[[label.id]]==targetname[i]]
			if(colorsnull)colors[object[[label.id]]==targetname[i]]="grey"
			lim=get_coord(target)
			lim$xlim[1]=lim$xlim[1]-context*lim$xlim[1]
			lim$xlim[2]=lim$xlim[2]+context*lim$xlim[2]
			lim$ylim[1]=lim$ylim[1]-context*lim$ylim[1]
			lim$ylim[2]=lim$ylim[2]+context*lim$ylim[2]
			li[[i]]=lim
		}
		xlim=c(min(sapply(li,function(x)min(x$xlim))),max(sapply(li,function(x)max(x$xlim))));
		ylim=c(min(sapply(li,function(x)min(x$ylim))),max(sapply(li,function(x)max(x$ylim))));
	
		# Plot target area:
		plot(map,col=colors,xlim=xlim,ylim=ylim,bg=bg,...)
		for(i in 1:length(targetname)) {
			obj1=map[object[[label.id]]==targetname[i]]
			obj2=obj1[[which(sapply(obj1,function(x)length(x))>0)]][[which.max(sapply(obj1[[which(sapply(obj1,function(x)length(x))>0)]],function(y)ifelse(is.null(dim(y[[1]])),1,dim(y[[1]])[1])))]]
			if(is.list(obj2))obj2=obj2[[1]]
			print(paste0("x=",mean(obj2[,1]),"y=",mean(obj2[,2])," : ",targetname[i]))
			if(!suppress.labels)text(mean(obj2[,1]),mean(obj2[,2]),ifelse((is.null(newlabel)|length(newlabel)!=length(targetname)),targetname[i],newlabel[i]),cex=cex)
		}
	}else{
		plot(map,col=colors,bg=bg,...)
	}
	return(object)
}

#####################################
# Examples
#####################################

if(F)
obj=plotThePlanet(targetname="Germany")

if(F)
obj=plotThePlanet(targetname=c("Germany","Afghanistan"),cex=.5)

if(F)
obj=plotThePlanet(c("Germany","Afghanistan","Turkey"),colors=c("red","purple","green"),cex=.5)

if(F)
obj=plotThePlanet(
targetname=c("90","09"),
newlabel=c("PLZ 90","PLZ 09"),
colors=NULL,
context=.01,
label.id="plz",
url="https://www.suche-postleitzahl.org/download_files/public/plz-2stellig.shp.zip",
files=c(
"plz-2stellig.shp",
"plz-2stellig.shx",
"plz-2stellig.dbf",
"plz-2stellig.prj")
)





