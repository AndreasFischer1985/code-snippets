 
addObject<-function(mat=NULL,name="glider",x=1,y=1){
    m=matrix(c(0,0,1, 1,1,0, 0,1,1),nrow=3);
    if(name=="sun") 	m=rbind(c(1,0,1,0,1,0),c(0,1,0,1,1,0),c(0,1,0,1,1,0),c(0,1,1,1,0,0),c(1,0,0,1,1,0))
    if(name=="r1") 	m=matrix(rbinom(1*1,1,.5),nrow=1) else
    if(name=="r2") 	m=matrix(rbinom(2*2,1,.5),nrow=2) else
    if(name=="r3") 	m=matrix(rbinom(3*3,1,.5),nrow=3) else
    if(name=="r4") 	m=matrix(rbinom(4*4,1,.5),nrow=4) else
    if(name=="r5") 	m=matrix(rbinom(5*5,1,.5),nrow=5) else
    if(name=="r10")	m=matrix(rbinom(10*10,1,.5),nrow=10) else
    if(name=="r-pentomino")m=matrix(c(0,1,0, 1,1,1, 1,0,0),nrow=3) else
    if(name=="glider")	m=matrix(c(1,1,0, 1,0,1, 1,0,0),nrow=3) else
    if(name=="LWSS")	m=matrix(c(1,1,1,1,0, 1,0,0,0,1, 1,0,0,0,0, 0,1,0,0,1),nrow=5) else
    if(name=="MWSS")	m=matrix(c(1,1,1,1,1,0, 1,0,0,0,0,1, 1,0,0,0,0,0, 0,1,0,0,0,1, 0,0,0,1,0,0),nrow=6) else                                    
    if(name=="HWSS")	m=matrix(c(1,1,1,1,1,1,0, 1,0,0,0,0,0,1, 1,0,0,0,0,0,0, 0,1,0,0,0,0,1, 0,0,0,1,1,0,0),nrow=7) else
    if(name=="loafer")	m=matrix(c(0,1,0,0,0,0,0,0,0, 1,0,1,0,0,0,0,0,0, 1,0,0,1,0,0,0,0,0, 0,1,1,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0, 1,0,0,0,0,0,1,0,0, 0,1,0,0,0,1,0,1,0, 1,1,0,0,0,1,0,0,1, 1,0,0,0,1,1,0,0,1),nrow=9) else
    if(name=="weekender")m=matrix(c( 0,0,1,0,0,0,0,0,0,0,0, 1,1,0,1,1,0,0,0,0,0,0, 0,0,1,0,0,1,0,1,0,0,0, 0,0,0,0,0,0,0,1,0,0,0, 0,0,0,0,0,0,0,1,0,1,0, 0,0,0,0,0,0,0,1,0,0,1, 0,0,0,0,0,1,1,0,0,0,1, 0,0,0,0,0,1,1,0,0,0,0, 
    0,0,0,0,0,1,1,0,0,0,0, 0,0,0,0,0,1,1,0,0,0,1, 0,0,0,0,0,0,0,1,0,0,1, 0,0,0,0,0,0,0,1,0,1,0, 0,0,0,0,0,0,0,1,0,0,0, 0,0,1,0,0,1,0,1,0,0,0, 1,1,0,1,1,0,0,0,0,0,0, 0,0,1,0,0,0,0,0,0,0,0),nrow=11) else
    if(name=="explo")m=matrix(c(1,1,1,0,1,1,1, 1,0,0,0,0,0,1, 1,1,1,0,1,1,1),nrow=7) else
    if(name=="glidergun.gosper")m=matrix(c(
    0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,1,1,0,0,0,0, 0,0,0,0,0,1,1,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,   
    0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,1,1,1,0,0,0, 0,0,0,0,1,0,0,0,1,0,0, 0,0,0,1,0,0,0,0,0,1,0, 0,0,0,1,0,0,0,0,0,1,0, 0,0,0,0,0,0,1,0,0,0,0, 0,0,0,0,1,0,0,0,1,0,0, 0,0,0,0,0,1,1,1,0,0,0, 0,0,0,0,0,0,1,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0, 
    0,0,0,0,0,0,0,0,0,0,0, 0,0,0,1,1,1,0,0,0,0,0, 0,0,0,1,1,1,0,0,0,0,0, 0,0,1,0,0,0,1,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0, 0,1,1,0,0,0,1,1,0,0,0, 0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0, 0,0,0,1,1,0,0,0,0,0,0, 0,0,0,1,1,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0
    ),nrow=11); 
    if(is.null(mat)) return(m) else
    for(i in 1:dim(m)[1])for(j in 1:dim(m)[2]) mat[i+(x-1),j+(y-1)]=m[i,j];
    return(mat);
}

addGlider=function(mat=NULL,x=1,y=1){addObject(mat=mat,name="glider",x=x,y=y);}
addLWSS=function(mat=NULL,x=1,y=1){addObject(mat=mat,name="LWSS",x=x,y=y);}
addMWSS=function(mat=NULL,x=1,y=1){addObject(mat=mat,name="MWSS",x=x,y=y);}
addHWSS=function(mat=NULL,x=1,y=1){addObject(mat=mat,name="HWSS",x=x,y=y);}
addLoafer=function(mat=NULL,x=1,y=1){addObject(mat=mat,name="loafer",x=x,y=y);}
addWeekender=function(mat=NULL,x=1,y=1){addObject(mat=mat,name="loafer",x=x,y=y);}
addExplo=function(mat=NULL,x=1,y=1){addObject(mat=mat,name="explo",x=x,y=y);}
addGlidergunGosper=function(mat=NULL,x=1,y=1){addObject(mat=mat,name="glidergun.gosper",x=x,y=y);}
addSun=function(mat=NULL,x=1,y=1){addObject(mat=mat,name="sun",x=x,y=y);}
 
world <- function(side=200, livingBorders=F, randomize=F){ 
	if(randomize) mat <- rbinom(side^2,1,0.5) else 
		      mat <- matrix(0,nrow=side, ncol=side)
  	if(livingBorders){
		mat[1,] <-1;
		mat[,1] <-1; 
		mat[side,] <-1; 
		mat[,side] <-1;
	}	
	return(mat)
} 

helloWorld<-function(){    
    v=rep(0,40000);
    m1=(matrix(v,nrow=sqrt(length(v))))
    m1=addObject(m1,"explo",20,180)
    m1=addObject(m1,"glidergun.gosper",10,10)
    m1=addObject(m1,"glider",20,60)
    m1=addObject(m1,"LWSS",170,10)
    m1=addObject(m1,"MWSS",180,20)
    m1=addObject(m1,"HWSS",190,30)
    m1=addObject(m1,"r-pentomino",100,100)    
    m1=addObject(m1,"loafer",180,150)
    m1=addObject(m1,"weekender",180,100)
    return(m1)
}

step <- function(mat, steps=1, expandable=F, storeAll=F, livingBorders=F){
	if(steps==1) storeAll=F	
	if(dim(mat)[1]!=dim(mat)[2] | is.null(dim(mat))) stop("Please provide a symmetric matrix")
	side=dim(mat)[1]
	if(storeAll) storage <- array(0, c(side, side, steps)) 
	for (i in 1:steps){
		if(expandable){
			if(sum(mat[1,])>0){     
			if(sum(mat[,1])>0)	mat=cbind(rep(0,side+1),rbind(rep(0,side),mat)) else
			if(sum(mat[,side])>0)   mat=cbind(rbind(rep(0,side),mat),rep(0,side+1)) else
						mat=cbind(rep(0,side+1),rbind(rep(0,side),mat)); side=dim(mat)[1]}
			if(sum(mat[side,])>0){	
			if(sum(mat[,1])>0)	mat=cbind(rep(0,side+1),rbind(mat,rep(0,side))) else
			if(sum(mat[,side])>0)   mat=cbind(rbind(mat,rep(0,side)),rep(0,side+1)) else
						mat=cbind(rep(0,side+1),rbind(mat,rep(0,side))); side=dim(mat)[1]}
			if(sum(mat[,1])>0){	
			if(sum(mat[1,])>0)	mat=cbind(rep(0,side+1),rbind(rep(0,side),mat)) else
			if(sum(mat[side,])>0)   mat=cbind(rep(0,side+1),rbind(mat,rep(0,side))) else
						mat=cbind(rep(0,side+1),rbind(rep(0,side),mat)); side=dim(mat)[1]}
			if(sum(mat[,side])>0){	
			if(sum(mat[1,])>0)	mat=cbind(rbind(rep(0,side),mat),rep(0,side+1)) else
			if(sum(mat[side,])>0)   mat=cbind(rbind(mat,rep(0,side)),rep(0,side+1)) else
						mat=cbind(rbind(rep(0,side),mat),rep(0,side+1)); side=dim(mat)[1]}	
			if(sum(mat)>0)
			mat=mat[(min(which(mat==1,arr.ind=T)[,1])-1):(max(which(mat==1,arr.ind=T)[,1])+1),
				(min(which(mat==1,arr.ind=T)[,2])-1):(max(which(mat==1,arr.ind=T)[,2])+1)]	
			toggle=T
			while(dim(mat)[1]<dim(mat)[2]){ 
				if(toggle==T) mat=rbind(mat,rep(0,dim(mat)[2])) else mat=rbind(rep(0,dim(mat)[2]),mat)
				toggle=!toggle 			
			}
			toggle=T
			while(dim(mat)[1]>dim(mat)[2]) {
				if(toggle==T) mat=cbind(mat,rep(0,dim(mat)[1])) else mat=cbind(rep(0,dim(mat)[1]),mat)
				toggle=!toggle 
			}
			side=dim(mat)[1]
		} 
	 		allW =  cbind(rep(0,side) , mat[,-side] )
			allNW = rbind(rep(0,side),cbind(rep(0,side-1),mat[-side,-side]))
			allN =  rbind(rep(0,side),mat[-side,])
			allNE = rbind(rep(0,side),cbind(mat[-side,-1],rep(0,side-1)))
			allE =  cbind(mat[,-1],rep(0,side))
			allSE = rbind(cbind(mat[-1,-1],rep(0,side-1)),rep(0,side))
			allS =  rbind(mat[-1,],rep(0,side))
			allSW = rbind(cbind(rep(0,side-1),mat[-1,-side]),rep(0,side))
		if(F){
			par(mfrow=c(3,3),mar=c(0,0,0,0))
			image(t(allNE),axes=F);box();image(t(allN),axes=F);box();image(t(allNW),axes=F);box();
			image(t(allE),axes=F);box();image(t(mat),axes=F);box(); image(t(allW),axes=F);box(); 
			image(t(allSE),axes=F);box();image(t(allS),axes=F);box();image(t(allSW),axes=F);box();	
		}
     		mat2 <- allW + allNW + allN + allNE + allE + allSE + allS + allSW
	    	mat3 <- mat
     		mat3[mat==0 & mat2==3] <- 1
     		mat3[mat==1 & mat2<2]  <- 0
     		mat3[mat==1 & mat2>3]  <- 0
     		mat <- mat3

     		if(livingBorders){mat[1,] <-1;mat[,1] <-1; mat[side,] <-1; mat[,side] <-1;}
     		if(storeAll)storage[,,i] <- mat #mat2 # note that I am storing the array of Ni values - this is in order to make the animation prettier
	}
	if(storeAll) return (storage) else
	return(mat)
}

plotWorld=function(mat, steps=0, type=1, pch=15, cex=.5, col="darkgreen", border="black", plot=T, expandable=T, box=T, bringToTop=T, ...) {
	if(length(dim(mat))==3) mat=mat[,,dim(mat)[3]]
	if(steps>0) mat=step(mat,steps=steps,storeAll=F,expandable=expandable)  
	if(plot!=F){
	if(type=="a" | type=="polygon" | type==1) 
	{
		x=as.data.frame(ifelse( length(dim(mat))==2, list(mat), list(mat[,,1]) )[[1]])
		plot(1:dim(mat)[1],1:dim(mat)[2],type="n",axes=F, xlab="", ylab="")
		invisible(lapply(1:dim(mat)[1],function(i){ 
			invisible(lapply(which(x[,i]==1), function(j) polygon(x=c(i-.5,i+.5,i+.5,i-.5),y=c(j-.5,j-.5,j+.5,j+.5),col=col, border=border) ))
		}))
	} else 
	if(type=="p" | type=="point" | type==2){
		x=as.data.frame(ifelse( length(dim(mat))==2, list(mat), list(mat[,,1]) )[[1]])
		plot(1:dim(mat)[1],1:dim(mat)[2],type="n",axes=F, xlab="", ylab="")
		invisible(lapply(1:dim(mat)[1],function(i){ points(which(x[i,]==1), rep(i,length(which(x[i,]==1))),pch=pch,cex=cex,col=col)}))
	} else
	if(type=="i" | type=="image" | type==3) { 
		image( t(ifelse( length(dim(mat))==2, list(mat), list(mat[,,1]) )[[1]]), axes=F, col=c(NA,col)) 
	} else
	{
		x=as.data.frame(ifelse( length(dim(mat))==2, list(mat), list(mat[,,1]) )[[1]])
		plot(1:dim(mat)[1],1:dim(mat)[2],type="n",axes=F, xlab="", ylab="")
		invisible(lapply(1:dim(mat)[1],function(i){ 
			invisible(lapply(which(x[,i]==1), function(j) polygon(x=c(i-.5,i+.5,i+.5,i-.5),y=c(j-.5,j-.5,j+.5,j+.5),col=col, border=border) ))
		}))
	}}
	if(box==T)box();
	if(bringToTop==T)bringToTop(-1) 
	return(invisible(mat))
}

evolveStepwise=function(mat,...){
	while(T) { 
		inp=as.character(readline(prompt="Input steps: "));
		inp[inp==""]=1;inp=as.numeric(inp);inp[is.na(inp)]=1;
		if(inp<0)break;
		mat=plotWorld(mat,steps=inp,...)
	}
	mat
}

#########################
# Demo Simulations
#########################

world1=world(10)
world1=addGlider(world1,5,5)
world1=plotWorld(world1,steps=1, expandable=F)


evos=list()
eval=sapply(1:5, function(i){
	set.seed(i);print(i)
	evo=addObject(NULL,"r5")#,x=20,y=20)
	evos[[i]]=plotWorld(evo,steps=1000, plot=F,expandable=T) 
	return( c(
		seed=i,
		average.mass=(sum(evos[[1]])+sum(step(evos[[i]],steps=1,storeAll=F))+sum(step(evos[[i]],steps=2,storeAll=F))+sum(step(evos[[i]],steps=3,storeAll=F))+sum(step(evos[[i]],steps=4,storeAll=F)))/5,
		max.dist=max((dim(evos[[i]])[1]-min(which(evos[[i]]==1,arr.ind=T))),(max(which(evos[[i]]==1,arr.ind=T))-(dim(evos[[i]])[1]+5))),
		side=dim(evos[[i]])[1]
	))
})
eval


set.seed(4);
world2=addObject(name="r5")
world2=evolveStepwise(world2) # enter negative number to quit evolution

