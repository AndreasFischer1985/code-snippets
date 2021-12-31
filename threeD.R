
#  8 ------ 7
# /|       /|
# 5 ------ 6|
# ||      | |
# |4 ------ 3
# |/      |/
# 1 ------2


#################################################################################
# Functions for rotating and plotting 3D-objects (points, wireframes or polygons)
#################################################################################

xRotate=function(theta,rver){
	while(theta>=360) theta=theta-360
	theta[theta<0]=0
	theta=theta*pi/180
	ct=cos(theta)
	st=sin(theta)
	rver2=rver
	rver2["yx"]=rver["yx"]*ct+rver["zx"]*st
	rver2["yy"]=rver["yy"]*ct+rver["zy"]*st
	rver2["yz"]=rver["yz"]*ct+rver["zz"]*st
	rver2["y0"]=rver["y0"]*ct+rver["z0"]*st
	rver2["zx"]=rver["zx"]*ct-rver["yx"]*st
	rver2["zy"]=rver["zy"]*ct-rver["yy"]*st
	rver2["zz"]=rver["zz"]*ct-rver["yz"]*st
	rver2["z0"]=rver["z0"]*ct-rver["y0"]*st
	rver2
}
yRotate=function(theta,rver){
	while(theta>=360) theta=theta-360
	theta[theta<0]=0
	theta=theta*pi/180
	ct=cos(theta)
	st=sin(theta)
	rver2=rver
	rver2["xx"]=rver["xx"]*ct+rver["zx"]*st
	rver2["xy"]=rver["xy"]*ct+rver["zy"]*st
	rver2["xz"]=rver["xz"]*ct+rver["zz"]*st
	rver2["x0"]=rver["x0"]*ct+rver["z0"]*st
	rver2["zx"]=rver["zx"]*ct-rver["xx"]*st
	rver2["zy"]=rver["zy"]*ct-rver["xy"]*st
	rver2["zz"]=rver["zz"]*ct-rver["xz"]*st
	rver2["z0"]=rver["z0"]*ct-rver["x0"]*st
	rver2
}
zRotate=function(theta,rver){
	while(theta>=360) theta=theta-360
	theta[theta<0]=0
	theta=theta*pi/180
	ct=cos(theta)
	st=sin(theta)
	rver2=rver
	rver2["yx"]=rver["yx"]*ct+rver["xx"]*st
	rver2["yy"]=rver["yy"]*ct+rver["xy"]*st
	rver2["yz"]=rver["yz"]*ct+rver["xz"]*st
	rver2["y0"]=rver["y0"]*ct+rver["x0"]*st
	rver2["xx"]=rver["xx"]*ct-rver["yx"]*st
	rver2["xy"]=rver["xy"]*ct-rver["yy"]*st
	rver2["xz"]=rver["xz"]*ct-rver["yz"]*st
	rver2["x0"]=rver["x0"]*ct-rver["y0"]*st
	rver2
}
scale=function(rver,fx,fy,fz){
	rver["xx"]=rver["xx"]*fx;rver["xy"]=rver["xy"]*fx;rver["xz"]=rver["xz"]*fx;rver["x0"]=rver["x0"]*fx
	rver["yx"]=rver["yx"]*fy;rver["yy"]=rver["yy"]*fy;rver["yz"]=rver["yz"]*fy;rver["y0"]=rver["y0"]*fy
	rver["zx"]=rver["zx"]*fz;rver["zy"]=rver["zy"]*fz;rver["zz"]=rver["zz"]*fz;rver["z0"]=rver["z0"]*fz
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
	rver["xx"]=1; rver["xy"]=0; rver["xz"]=0; rver["x0"]=0
	rver["yx"]=0; rver["yy"]=1; rver["yz"]=0; rver["y0"]=0
	rver["zx"]=0; rver["zy"]=0; rver["zz"]=1; rver["z0"]=0
	rver
}
toString=function(rver) {
	x=paste0("[",rver["x0"],",",rver["xx"],",",rver["xy"],",",rver["xz"],";\n",
		     rver["y0"],",",rver["yx"],",",rver["yy"],",",rver["yz"],";\n",
		     rver["z0"],",",rver["zx"],",",rver["zy"],",",rver["zz"],"]");
	message(x);return(x);
}
form=function(form="cube")
	if(form=="cube") {
		message("  8 ------ 7 \n /|       /| \n 5 ------ 6| \n ||      | | \n |4 ------ 3 \n |/      |/  \n 1 ------2   ")
		return(list(
		"ver"=c(-1,-1,-1, +1,-1,-1, +1,-1,+1, -1,-1,+1, -1,+1,-1, +1,+1,-1, +1,+1,+1, -1,+1,+1),
		"con"=c(1,2, 2,3, 3,4, 1,4, 5,6, 6,7, 7,8, 5,8, 1,5, 2,6, 3,7, 4,8),
		"pol"=c(1,2,3, 1,3,4, 5,6,7, 5,7,8, 1,2,5, 2,5,6, 2,3,7, 2,6,7, 1,4,8, 1,5,8, 3,4,8, 3,7,8)))
	}
toVer=function(x,y,z){
	c(sapply(1:length(x), function(i) c(x[i],y[i],z[i])))
}
transform=function(ver,rver,thetaX=NULL,thetaY=NULL,thetaZ=NULL,persp=0){
	tver=ver*0
	if(!is.null(thetaX)) rver=xRotate(thetaX,rver)
	if(!is.null(thetaY)) rver=yRotate(thetaY,rver)
	if(!is.null(thetaZ)) rver=zRotate(thetaZ,rver)
	for(i in seq(length(ver),1,by=-3)-2){
		tver[i+0]=ver[i]*rver["xx"]+ver[i+1]*rver["xy"]+ver[i+2]*rver["xz"]+rver["x0"]
		tver[i+1]=ver[i]*rver["yx"]+ver[i+1]*rver["yy"]+ver[i+2]*rver["yz"]+rver["y0"]
		tver[i+2]=ver[i]*rver["zx"]+ver[i+1]*rver["zy"]+ver[i+2]*rver["zz"]+rver["z0"]
		if(persp>0){
			tver[i+0]=tver[i+0]*(1-tver[i+2]/persp)
			tver[i+1]=tver[i+1]*(1-tver[i+2]/persp)
		}
	}
	return(tver)
}
vectorLength=function(...)sqrt(sum(sapply(...,function(x)x^2)))
vectorDistance=function(a,b)sqrt(sum(sapply(1:length(a),function(i)(a[i]-b[i])^2)))
polygonArea=function(a,b,c) (a[1]*b[2]-a[2]*b[1] + b[1]*c[2]-b[2]*c[1] + b[1]*a[2]-b[2]*a[1])/2
crossProduct <- function(x,y) {
	if (is.vector(x) && is.vector(y)) {
		if (length(x) == length(y) && length(x) == 3) {
			xxy <- c(x[2]*y[3] - x[3]*y[2],
			        x[3]*y[1] - x[1]*y[3],
    		         	x[1]*y[2] - x[2]*y[1])
		}
	} else {
		if (is.matrix(x) && is.matrix(y)) {
			if (all(dim(x) == dim(y))) {
				if (ncol(x) == 3) {
                    			xxy <- cbind(x[, 2]*y[, 3] - x[, 3]*y[, 2],
        			             	x[, 3]*y[, 1] - x[, 1]*y[, 3],
            		             		x[,1 ]*y[, 2] - x[, 2]*y[, 1])
				} else {
					if (nrow(x) == 3) {
                        			xxy <- rbind(x[2, ]*y[3, ] - x[3, ]*y[2, ],
            			             	x[3, ]*y[1, ] - x[1, ]*y[3, ],
                		             	x[1, ]*y[2, ] - x[2, ]*y[1, ])
					}
				}
			}
		} 
	}
	return(xxy)
}		 
colourPolygons=function(tver,pol,col1="lightgrey",returnDegree=F){
	d=numeric(0)
	toDegree <- function(rad) rad * 57.29577951308232286465 # double for 180/pi
	for(i in seq(1,length(pol),by=3)){
		x1=tver[pol[i]*3-2];y1=tver[pol[i]*3-1];z1=tver[pol[i]*3-0]
		x2=tver[pol[i+1]*3-2];y2=tver[pol[i+1]*3-1];z2=tver[pol[i+1]*3-0]
		x3=tver[pol[i+2]*3-2];y3=tver[pol[i+2]*3-1];z3=tver[pol[i+2]*3-0]
		v1=(y1-y2)*(z3-z2)-(z1-z2)*(y3-y2)
		v2=(z1-z2)*(x3-x2)-(x1-x2)*(z3-z2)
		v3=(x1-x2)*(y3-y2)-(y1-y2)*(x3-x2)
		d=c(d,asin(sqrt((v1*v1+v2*v2)/(v1*v1+v2*v2+v3*v3))))
	}
	d=toDegree(d)
	if(returnDegree) return(d)
	d=round(d)
	cols=unlist(lapply(1:length(d),function(i){
		apply(col2rgb(col1), 2, function(x)
			rgb( max(0,min(1,(x[1]-d[i])/255)),max(0,min(1,(x[2]-d[i])/255)),max(0,min(1,(x[3]-d[i])/255)) )
		)
	}))
	cols
 	}
sortCon=function(con,tver,fun=mean){
	if(is.null(fun)) fun=mean
	for(i in seq(1,length(con),by=2))
	for(j in seq(1,length(con),by=2))
	if(fun(c(tver[con[i]*3],ver[con[i+1]*3])) > fun(c(tver[con[j]*3],tver[con[j+1]*3]))){
		h1=con[i];h2=con[i+1];
		con[i]=con[j];con[i+1]=con[j+1];
		con[j]=h1;con[j+1]=h2;
	}
	con
}
sortPol=function(pol,tver,fun=mean){
	if(is.null(fun)) fun=mean
	for(i in seq(1,length(pol),by=3))
	for(j in seq(1,length(pol),by=3))
	if(fun(c(tver[pol[i]*3],tver[pol[i+1]*3],tver[pol[i+2]*3])) > fun(c(tver[pol[j]*3],tver[pol[j+1]*3],tver[pol[j+2]*3]))){
		h1=pol[i];h2=pol[i+1];h3=pol[i+2];
		pol[i]=pol[j];pol[i+1]=pol[j+1];pol[i+2]=pol[j+2];
		pol[j]=h1;pol[j+1]=h2;pol[j+2]=h3;
	}
	return(pol)
}
plotPoints=function(tver,rver,con,add=F,col1="lightgrey",col2="black",subset=NULL,lim=NULL){
	if(is.null(lim)) {
	if(add==F) plot(c(min(tver),max(tver)),c(min(tver),max(tver)),type="n",axes=F,xlab=NA,ylab=NA)}else
	if(add==F) plot(c(lim[1],lim[2]),c(lim[1],lim[2]),type="n",axes=F,xlab=NA,ylab=NA)
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
plotWireframe=function(tver,rver,con,add=F,col1="lightgrey",col2="black",subset=NULL,lim=NULL,fun=mean){
	if(is.null(lim)) {
	if(add==F) plot(c(min(tver),max(tver)),c(min(tver),max(tver)),type="n",axes=F,xlab=NA,ylab=NA)}else
	if(add==F) plot(c(lim[1],lim[2]),c(lim[1],lim[2]),type="n",axes=F,xlab=NA,ylab=NA)
	con=sortCon(con,tver,fun);
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
plotPolygons=function(tver,rver,pol,add=F,col1="lightgrey",col2="black",subset=NULL,border="black",lim=NULL,fun=mean){
	if(is.null(lim)) {
	if(add==F) plot(c(min(tver),max(tver)),c(min(tver),max(tver)),type="n",axes=F,xlab=NA,ylab=NA)}else
	if(add==F) plot(c(lim[1],lim[2]),c(lim[1],lim[2]),type="n",axes=F,xlab=NA,ylab=NA)
	pol=sortPol(pol,tver,fun);
	z=sapply(seq(1,length(pol),by=3),function(i) (tver[pol[i]*3]+tver[pol[i+1]*3]+tver[pol[i+2]*3])/3)
	cols=colourPolygons(tver,pol,col1)
	if(!is.null(subset)){
		if(subset=="front")cols[z>0]=NA
		if(subset=="back")cols[z<=0]=NA
	}
	co=0
	for(i in seq(1,length(pol),by=3)){
		co=co+1
		polygon(
			x=c(tver[pol[i]*3-2],tver[pol[i+1]*3-2],tver[pol[i+2]*3-2]),
			y=c(tver[pol[i]*3-1],tver[pol[i+1]*3-1],tver[pol[i+2]*3-1]),
			col=cols[co],border=border)
	}
}

####################
# Example
####################

ver=form()$ver
con=form()$con
pol=form()$pol

set.seed(0);
poi=toVer(x=rnorm(100)/4,y=rnorm(100)/4,z=rnorm(100)/4);poi[poi>1]=1

nv=length(ver)/3
nc=length(con)/2
rver=unit()

tver=transform(ver,rver,thetaX=320,thetaY=320,thetaZ=0)
tver2=transform(poi,rver,thetaX=320,thetaY=320,thetaZ=0)

dev.new();
plotPolygons(tver,rver,pol,subset="back",border=NA, add=F);
plotPoints(tver2,rver,con,add=T)

dev.new();
plotWireframe(tver,rver,con,add=F,subset="back")
plotPoints(tver2,rver,con,add=T)
plotWireframe(tver,rver,con,add=T,subset="front")

dev.new();
par(mfrow=c(4,10))
a=seq(10,360,length.out=10);
for(i in a) {par(mar=c(0,0,0,0));tver=transform(ver,rver,thetaX=i,thetaY=0,thetaZ=0);plotPolygons(tver,rver,pol,border="blue", lim=c(-2,2), add=F);}
for(i in a) {par(mar=c(0,0,0,0));tver=transform(ver,rver,thetaX=0,thetaY=i,thetaZ=0);plotPolygons(tver,rver,pol,border="blue", lim=c(-2,2), add=F);}
for(i in a) {par(mar=c(0,0,0,0));tver=transform(ver,rver,thetaX=0,thetaY=0,thetaZ=i);plotPolygons(tver,rver,pol,border="blue", lim=c(-2,2), add=F);}
for(i in a) {par(mar=c(0,0,0,0));tver=transform(ver,rver,thetaX=i,thetaY=i,thetaZ=i);plotPolygons(tver,rver,pol,border="blue", lim=c(-2,2), add=F);}


dev.new();
p=function(a=F,tx=0,ty=0,tz=0){
print(paste(tx,";",ty,";",tz))
	tver=transform(ver,rver,thetaX=tx,thetaY=ty,thetaZ=tz);
	plotPolygons(tver,rver,pol,border="blue", lim=c(-2,2), add=a);
}
p(F)
prevx=0;prevy=0;ax=0;ay=0;thetax=0;thetay=0;drag=F;
toDegree <- function(rad) rad * 57.29577951308232286465 
toRadians <- function(deg) deg / 57.29577951308232286465 
f=function(prompt="Move the cube with cursor keys") getGraphicsEvent(
	prompt=prompt,
	onKeybd=function(x){
		if(x=="ctrl-["){ print(paste("thetax=",thetax,"; thetay=",thetay)); return("ctrl-[")}
		if(x=="Down")  thetax<<-thetax+5
		if(x=="Left")  thetay<<-thetay+5
		if(x=="Right") thetay<<-thetay-5
		if(x=="Up")    thetax<<-thetax-5
		if(thetax>360)thetax<<-thetax-360
		if(thetay>360)thetay<<-thetay-360
		if(thetax<0)thetax<<-360+thetax
		if(thetay<0)thetay<<-360+thetay
		p(F,thetax,thetay);
		f(paste(x,"; ",thetax,";",thetay));
		return(-1)
		NULL}
)
f()

