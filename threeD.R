#################################################################################
# Functions for rotating and plotting 3D-objects (points, wireframes or polygons)
#################################################################################

xRotate=function(theta,rver){
	theta=theta*pi/180
	ct=cos(theta)
	st=sin(theta)
	rver["yx"]=rver["yx"]*ct+rver["zx"]*st
	rver["yy"]=rver["yy"]*ct+rver["zy"]*st
	rver["yz"]=rver["yz"]*ct+rver["zz"]*st
	rver["y0"]=rver["y0"]*ct+rver["z0"]*st
	rver["zx"]=rver["zx"]*ct-rver["yx"]*st
	rver["zy"]=rver["zy"]*ct-rver["yy"]*st
	rver["zz"]=rver["zz"]*ct-rver["yz"]*st
	rver["z0"]=rver["z0"]*ct-rver["y0"]*st
	rver
}
yRotate=function(theta,rver){
	theta=theta*pi/180
	ct=cos(theta)
	st=sin(theta)
	rver["xx"]=rver["xx"]*ct+rver["zx"]*st
	rver["xy"]=rver["xy"]*ct+rver["zy"]*st
	rver["xz"]=rver["xz"]*ct+rver["zz"]*st
	rver["x0"]=rver["x0"]*ct+rver["z0"]*st
	rver["zx"]=rver["zx"]*ct-rver["xx"]*st
	rver["zy"]=rver["zy"]*ct-rver["xy"]*st
	rver["zz"]=rver["zz"]*ct-rver["xz"]*st
	rver["zz0"]=rver["z0"]*ct-rver["x0"]*st
	rver
}
zRotate=function(theta,rver){
	theta=theta*pi/180
	ct=cos(theta)
	st=sin(theta)
	rver["yx"]=rver["yx"]*ct+rver["xx"]*st
	rver["yy"]=rver["yy"]*ct+rver["xy"]*st
	rver["yz"]=rver["yz"]*ct+rver["xz"]*st
	rver["y0"]=rver["y0"]*ct+rver["x0"]*st
	rver["xx"]=rver["xx"]*ct-rver["yx"]*st
	rver["xy"]=rver["xy"]*ct-rver["yy"]*st
	rver["xz"]=rver["xz"]*ct-rver["yz"]*st
	rver["x0"]=rver["x0"]*ct-rver["y0"]*st
	rver
}
scale=function(rver,fx,fy,fz){
	rver["xx"]=rver["xx"]*fx
	rver["xy"]=rver["xy"]*fx
	rver["xz"]=rver["xz"]*fx
	rver["x0"]=rver["x0"]*fx
	rver["yx"]=rver["yx"]*fy
	rver["yy"]=rver["yy"]*fy
	rver["yz"]=rver["yz"]*fy
	rver["y0"]=rver["y0"]*fy
	rver["zx"]=rver["zx"]*fz
	rver["zy"]=rver["zy"]*fz
	rver["zz"]=rver["zz"]*fz
	rver["z0"]=rver["z0"]*fz
	rver
}
translate=function(rver,fx,fy,fz){
	rver["x0"]=rver["x0"]+fx
	rver["y0"]=rver["y0"]+fy
	rver["z0"]=rver["z0"]+fz
	rver
}
unit=function(){
	rver=numeric(0)
	rver["xx"]=1
	rver["xy"]=0
	rver["xz"]=0
	rver["x0"]=0
	rver["yx"]=0
	rver["yy"]=1
	rver["yz"]=0
	rver["y0"]=0
	rver["zx"]=0
	rver["zy"]=0
	rver["zz"]=1
	rver["z0"]=0
	rver
}
form=function(form="cube") 
	if(form=="cube") return(list(
		"ver"=c(-1,-1,-1, +1,-1,-1, +1,-1,+1, -1,-1,+1, -1,+1,-1, +1,+1,-1, +1,+1,+1, -1,+1,+1),
		"con"=c(1,2, 2,3, 3,4, 1,4, 5,6, 6,7, 7,8, 5,8, 1,5, 2,6, 3,7, 4,8),
		"pol"=c(1,2,3, 1,3,4, 5,6,7, 5,7,8, 1,2,5, 2,5,6, 2,3,7, 2,6,7, 1,4,8, 1,5,8, 3,4,8, 3,7,8)))

transform=function(ver,rver,thetaX=NULL,thetaY=NULL,thetaZ=NULL){
	tver=ver*0
	if(!is.null(thetaX)) rver=xRotate(thetaX,rver)
	if(!is.null(thetaY)) rver=yRotate(thetaY,rver)
	if(!is.null(thetaZ)) rver=zRotate(thetaZ,rver)
	for(i in seq(1,length(ver),by=3)){
		tver[i+0]=ver[i]*rver["xx"]+ver[i+1]*rver["xy"]+ver[i+2]*rver["xz"]+rver["x0"]
		tver[i+1]=ver[i]*rver["yx"]+ver[i+1]*rver["yy"]+ver[i+2]*rver["yz"]+rver["y0"]
		tver[i+2]=ver[i]*rver["zx"]+ver[i+1]*rver["zy"]+ver[i+2]*rver["zz"]+rver["z0"]
	}
	return(tver)
}
sortCon=function(con,tver){
	for(i in seq(1,length(con),by=2))
	for(j in seq(1,length(con),by=2))
	if((tver[con[i]*3]+tver[con[i+1]*3])/2 > (tver[con[j]*3]+tver[con[j+1]*3])/2){
		h1=con[i];h2=con[i+1];
		con[i]=con[j];con[i+1]=con[j+1];
		con[j]=h1;con[j+1]=h2;
	}
	con
}
sortPol=function(pol,tver){
	for(i in seq(1,length(pol),by=3))
	for(j in seq(1,length(pol),by=3))
	if((tver[pol[i]*3]+tver[pol[i+1]*3]+tver[pol[i+2]*3])/3 > (tver[pol[j]*3]+tver[pol[j+1]*3]+tver[pol[j+2]*3])/3){
		h1=pol[i];h2=pol[i+1];h3=pol[i+2];
		pol[i]=pol[j];pol[i+1]=pol[j+1];pol[i+2]=pol[j+2];
		pol[j]=h1;pol[j+1]=h2;pol[j+2]=h3;
	}
	pol
}
plotWireframe=function(tver,rver,con,add=F,col1="lightgrey",col2="black",subset=NULL){
	if(add==F) plot(c(min(tver),max(tver)),c(min(tver),max(tver)),type="n",axes=F,xlab=NA,ylab=NA)
	con=sortCon(con,tver);
	z=sapply(seq(1,length(con),by=2),function(i) (tver[con[i]*3]+tver[con[i+1]*3])/2)
	cols=colorRampPalette(c(col2,col1))(length(levels(as.factor(z))));
	if(!is.null(subset)){
		if(subset=="front")cols[z<=0]=NA
		if(subset=="back")cols[z>0]=NA
	}
	co=0
	for(i in seq(1,length(con),by=2)){
		co=co+1
		segments(tver[con[i]*3-2],tver[con[i]*3-1],tver[con[i+1]*3-2],tver[con[i+1]*3-1],
		col=cols[rank(z,ties.method="min")[co]])
	}
}
plotPolygons=function(tver,rver,pol,add=F,col1="lightgrey",col2="black",subset=NULL,border="black"){
	if(add==F) plot(c(min(tver),max(tver)),c(min(tver),max(tver)),type="n",axes=F,xlab=NA,ylab=NA)
	pol=sortPol(pol,tver);
	z=sapply(seq(1,length(pol),by=3),function(i) (tver[pol[i]*3]+tver[pol[i+1]*3]+tver[pol[i+2]*3])/3)
	cols=colorRampPalette(c(col2,col1))(length(levels(as.factor(z))));
	if(!is.null(subset)){
		if(subset=="front")cols[z<=0]=NA
		if(subset=="back")cols[z>0]=NA
	}
	co=0
	for(i in seq(1,length(pol),by=3)){
		co=co+1
		polygon(
			x=c(tver[pol[i]*3-2],tver[pol[i+1]*3-2],tver[pol[i+2]*3-2]),
			y=c(tver[pol[i]*3-1],tver[pol[i+1]*3-1],tver[pol[i+2]*3-1]),
		col=cols[rank(z,ties.method="min")[co]],border=border)
	}
}
plotPoints=function(tver,rver,con,add=F,col1="lightgrey",col2="black",subset=NULL){
	if(add==F) plot(c(min(tver),max(tver)),c(min(tver),max(tver)),type="n",axes=F,xlab=NA,ylab=NA)
	z=sapply(seq(1,length(tver),by=3),function(i) tver[i+2])
	cols=colorRampPalette(c(col2,col1))(length(levels(as.factor(z))));
	if(!is.null(subset)){
		if(subset=="front")cols[z<=0]=NA
		if(subset=="back")cols[z>0]=NA
	}
	co=0
	for(i in seq(1,length(tver),by=3)){
		co=co+1
		points(tver[i+0],tver[i+1],pch=16,col=cols[rank(z,ties.method="min")[co]]) 
	}
}


####################
# Example
####################

ver=form()$ver
con=form()$con
pol=form()$pol

nv=length(ver)/3
nc=length(con)/2
rver=unit()
tver=transform(ver,rver,thetaX=30,thetaY=20)

plotPolygons(tver,rver,pol,subset="back",add=F)
plotWireframe(tver,rver,con,add=T)
plotPoints(tver,rver,con,add=T)
