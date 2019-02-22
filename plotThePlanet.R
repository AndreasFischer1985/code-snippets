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
	bg='lightblue',
	bg2='olivedrab3',
	fg='palegreen',
	subset=T,
	xlim=NULL,
	ylim=NULL,
	...
){
	library(stringr)

	mar=par("mar");
	par(mar = c(0,0,0,0));

	# Download and unzip zip-file if necessary
	if(length(grep("[.]zip$",url))>0){
		if(sum(!file.exists(files))>0)
		download.file(url,"plotThePlanetMap.zip");
		unzip("plotThePlanetMap.zip");
		file.remove("plotThePlanetMap.zip")
	}

	# Download data and metadata (i.e. the "files") if necessary:
	for(file in files) if(!file.exists(file)) download.file(paste0(url,file),file,mode = "wb")

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
	if(is.null(colors)){colors=rep(bg2,length(map));colorsnull=T}
	if(!colorsnull&length(colors)>1&length(colors)<length(map)&length(colors)==length(targetname)){
		colors2=rep(bg2,length(map));
		for(i in 1:length(targetname))colors2[object[[label.id]]==targetname[i]]=colors[i];
		colors=colors2;
	}	
	if(!is.null(targetname)){
		li=list()
		if(is.null(xlim)|is.null(ylim)){
			for(i in 1:length(targetname)){	
				target=map[object[[label.id]]==targetname[i]]
				if(colorsnull)colors[object[[label.id]]==targetname[i]]=fg
				lim=get_coord(target)
				lim$xlim[1]=lim$xlim[1]-context*lim$xlim[1]
				lim$xlim[2]=lim$xlim[2]+context*lim$xlim[2]
				lim$ylim[1]=lim$ylim[1]-context*lim$ylim[1]
				lim$ylim[2]=lim$ylim[2]+context*lim$ylim[2]
				li[[i]]=lim
			}}else li=list(list(xlim=xlim),list(ylim=ylim))
		if(is.null(xlim))xlim=c(min(sapply(li,function(x)min(x$xlim))),max(sapply(li,function(x)max(x$xlim))));
		if(is.null(ylim))ylim=c(min(sapply(li,function(x)min(x$ylim))),max(sapply(li,function(x)max(x$ylim))));
		print(paste0("xlim=c(",xlim[1],",",xlim[2],"); ylim=c(",ylim[1],",",ylim[2],")"))

		# Plot target area:
		if(subset){
			b1=sapply(map,sf::st_bbox)
			keep=(b1[1,]>xlim[1]|b1[3,]<xlim[2]|b1[2,]>ylim[1]|b1[4,]<ylim[2]);
			plot(map[keep],col=colors[keep],xlim=xlim,ylim=ylim,bg=bg,...)
		}else
			plot(map,col=colors,xlim=xlim,ylim=ylim,bg=bg,...)
 
		for(i in 1:length(targetname)) {
			obj1=map[object[[label.id]]==targetname[i]]
			obj2=obj1[[which(sapply(obj1,function(x)length(x))>0)]][[which.max(sapply(obj1[[which(sapply(obj1,function(x)length(x))>0)]],function(y)ifelse(is.null(dim(y[[1]])),1,dim(y[[1]])[1])))]]
			if(is.list(obj2))obj2=obj2[[1]]
			x1=suppressWarnings(na.omit(sf::st_coordinates(sf::st_centroid(obj1))[,1])[1])
			y1=suppressWarnings(na.omit(sf::st_coordinates(sf::st_centroid(obj1))[,2])[1])
			print(paste0(targetname[i],": centroid(x)=",x1,"; centroid(y)=",y1))
			#print(paste0("mean(x)=",mean(obj2[,1]),"mean(y)=",mean(obj2[,2])," : ",targetname[i]))
			if(!suppress.labels)text(x1,y1,ifelse((is.null(newlabel)|length(newlabel)!=length(targetname)),targetname[i],newlabel[i]),cex=cex)
			}
	}else{
		b1=sf::st_bbox(map);xlim=c(b1[1],b1[3]);ylim=c(b1[2],b1[4])
		print(paste0("xlim=c(",xlim[1],",",xlim[2],"); ylim=c(",ylim[1],",",ylim[2],")"))
		plot(map,col=colors,bg=bg,...)
		
	}

	par(mar=mar)
	return(object)
}

#####################################
# Examples
#####################################


if(T)
obj=plotThePlanet(c("Germany","Afghanistan","Turkey"),colors=c("red","purple","green"),cex=.5)

if(F){
obj=plotThePlanet(targetname="Germany",context=.05)
centroids= t(sapply(sf::st_centroid(sf::st_geometry(obj)),function(x)c(x[1],x[2])))
#quantqual::boxedText(centroids[,1],centroids[,2],paste0(" ",obj$NAME_EN," "),cex=1,decollide=T,vspace=1.8,hspace=1)
}

if(F){
obj=plotThePlanet(
#targetname=c("Bayern"),
colors=NULL,
context=.01,
label.id="NAME_1",
url="https://biogeo.ucdavis.edu/data/gadm3.6/shp/gadm36_DEU_shp.zip",
files=c(
"gadm36_DEU_1.shp",
"gadm36_DEU_1.shx",
"gadm36_DEU_1.cpg",
"gadm36_DEU_1.dbf",
"gadm36_DEU_1.prj"
),
bg="grey"
)
centroids= t(sapply(sf::st_centroid(sf::st_geometry(obj)),function(x)c(x[1],x[2])))
#quantqual::boxedText(centroids[,1],centroids[,2],paste0(" ",obj$NAME_1," "),cex=.7,decollide=T,vspace=1.8,hspace=1)
}


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
"plz-2stellig.prj"),
bg="grey"
)



