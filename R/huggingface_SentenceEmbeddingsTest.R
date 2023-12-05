#############################################################################
# Title:  FOSS Sentence Embeddings - Embeddings deutscher Texte im Vergleich
# Author: Dr. Andreas Fischer
# Date:   15.11.2023
#############################################################################

api_token= [API-Token] # insert your Huggingface API-token here

setwd("C:/Users/fischer.andreas/Documents/WIP/AG-R/KI_Prototypen/SentenceEmbeddingsTest")
#load("wip.RData")
#save.image("wip.RData")

# Get German Project Titles from f-bb-Homepage
#----------------------------------------------
 
url="https://www.f-bb.de/unsere-arbeit/projekte/"
response=httr::GET(url)
#status=httr::http_status(response)
#content=httr::content(response, as="text")
#x=as.character(response)
#x=qqBaseX::matchAll(x,"ergebnis(.*?)</div>")
x=as.character(response)
x=strsplit(x,"<")[[1]]
x=x[grep("\"ergebnis\"",x)+1]
x=gsub(".*>","",x)
titles=x


# Generate synonymous alternative Project Titels
#------------------------------------------------
prompts=paste0("###Frage: Wie könnte man das Projekt \"",titles,"\" umbenennen, sodass nach wie vor deutlich wird worum es geht? ###Antwort: Ein geeigneter Projekttitel wäre: \"")

r=list()
for(i in 1:length(prompts)){
	print(paste0(i,"/",length(prompts)," started at ",Sys.time()))
	p=prompts[i]
	print(paste0("Prompt: ",p))
	url="https://afischer1985-wizardlm-13b-v1-2-q4-0-gguf.hf.space/v1/completions"
	#url="http://192.168.2.42:2600/v1/completions" # local llama-cpp-server
	body=list(
  		"prompt"=p,
  		"max_tokens"=128,
  		"stop"=c("###","\""))
	response=httr::POST(url=url,body=body, encode="json")
	content=httr::content(response)
	r[[i]]=content
	writeLines(paste(p,"\n",paste(as.character(content),collapse="\n\n")),
		paste0("Textentwurf_",i,".txt"))
	print(paste0("Response: ",content))
}
titles2=sapply(r,function(x)x$choices[[1]]$text)
titles2[1]=gsub(".*\"","",gsub("\"\n\n.*","",titles2[1]))
head(titles2)

dat=data.frame(
		"Projektitel"=titles,
		"Prompt"=prompts,
		"Alternativtitel"=titles2)
write.csv2(dat,	"SynthetsicheProjektitel.csv")


# Generate sentence embeddings 1 by WizardLM-13b-v1.2
#-----------------------------------------------------

t0=Sys.time()
prompts=titles
e=list()
for(i in 1:length(prompts)){
	print(paste0(i,"/",length(prompts)," started at ",Sys.time()))
	p=prompts[i]
	print(paste0("Prompt: ",p))
	url="https://afischer1985-wizardlm-13b-v1-2-q4-0-gguf.hf.space/v1/embeddings"
	#url="http://192.168.2.42:2600/v1/embeddings" # local llama-cpp-server
	body=list(
  		"input"=p)
	response=httr::POST(url=url,body=body, encode="json")
	content=httr::content(response)
	e[[i]]=content
	writeLines(paste(p,"\n",paste(as.character(content),collapse="\n\n")),
		paste0("Embedding_a_",i,".txt"))
	print(paste0("Response ",i))
}
t1=Sys.time()
t1-t0
embeddings_a_1=t(sapply(e,function(x)x$data[[1]]$embedding))
write.csv2(embeddings_a_1,"embeddings_a_1.csv")

t0=Sys.time()
prompts=titles2
e=list()
for(i in 1:length(prompts)){
	print(paste0(i,"/",length(prompts)," started at ",Sys.time()))
	p=prompts[i]
	print(paste0("Prompt: ",p))
	url="https://afischer1985-wizardlm-13b-v1-2-q4-0-gguf.hf.space/v1/embeddings"
	#url="http://192.168.2.42:2600/v1/embeddings" # local llama-cpp-server
	body=list(
  		"input"=p)
	response=httr::POST(url=url,body=body, encode="json")
	content=httr::content(response)
	e[[i]]=content
	writeLines(paste(p,"\n",paste(as.character(content),collapse="\n\n")),
		paste0("Embedding_b_",i,".txt"))
	print(paste0("Response ",i))
}
t1=Sys.time()
t1-t0
embeddings_b_1=t(sapply(e,function(x)x$data[[1]]$embedding))
write.csv2(embeddings_b_1,"embeddings_b_1.csv")

length(e[[1]])


# Generate sentence embeddings 2 by German-roberta-sentence-transformer-v2
#-------------------------------------------------------------------------

# Get sentence embeddings of titles via Huggingface API
require("httr")
model_id = "T-Systems-onsite/german-roberta-sentence-transformer-v2" 
e=list()
t0=Sys.time()
prompts=titles
e=list()
for(i in 1:length(prompts)){
  print(paste0(i,"/",length(prompts)," started at ",Sys.time()))
  payload=prompts[i]
  #payload = "Roses are red"
  url=paste0("https://api-inference.huggingface.co/models/",model_id)
  post=httr::POST(url=url, body=list("inputs"= payload), 
  	httr::add_headers(.headers=c("X-Wait-For-Model"="true","X-Use-Cache"="false")),	
	httr::add_headers(.headers=c("Authorization"=paste("Bearer",api_token))),
 	encode="json")
  x=httr::content(post)
  print(length(x[[1]][[1]]))
  e[[i]]=x
}
t1=Sys.time()
t1-t0
#sapply(e,length) 
sentenceEmbeddings = lapply(e,function(f){
  #x=as.matrix(wapply(f,function(x)(x)))
  x=do.call(cbind,f[[1]])
  x=apply(x,2,as.numeric)
  rowMeans(x) # Mean-Pooling der Token-Embeddings
})
embeddings_a_2=do.call(rbind,sentenceEmbeddings)
dim(embeddings_a_2)
write.csv2(embeddings_a_2,"embeddings_a_2.csv")
embeddings_a_2=read.csv2("embeddings_a_2.csv")[,-1]

# Get sentence embeddings of titles2 via Huggingface API
require("httr")
model_id = "T-Systems-onsite/german-roberta-sentence-transformer-v2" 
e=list()
t0=Sys.time()
prompts=titles2
e=list()
for(i in 1:length(prompts)){
  print(paste0(i,"/",length(prompts)," started at ",Sys.time()))
  payload=prompts[i]
  #payload = "Roses are red"
  url=paste0("https://api-inference.huggingface.co/models/",model_id)
  post=httr::POST(url=url, body=list("inputs"= payload), 
  	httr::add_headers(.headers=c("X-Wait-For-Model"="true","X-Use-Cache"="false")),	
	httr::add_headers(.headers=c("Authorization"=paste("Bearer",api_token))),
 	encode="json")
  x=httr::content(post)
  print(length(x[[1]][[1]]))
  e[[i]]=x
}
t1=Sys.time()
t1-t0
#sapply(e,length) 
sentenceEmbeddings = lapply(e,function(f){
  #x=as.matrix(wapply(f,function(x)(x)))
  x=do.call(cbind,f[[1]])
  x=apply(x,2,as.numeric)
  rowMeans(x) # Mean-Pooling der Token-Embeddings
})
embeddings_b_2=do.call(rbind,sentenceEmbeddings)
dim(embeddings_b_2)
write.csv2(embeddings_b_2,"embeddings_b_2.csv")
embeddings_b_2=read.csv2("embeddings_b_2.csv")[,-1]


# Generate sentence embeddings 3 by Instructor-large from WISY@KI
#-------------------------------------------------------------------------
# https://documenter.getpostman.com/view/5192576/2s935pqP3v#20a20689-c97f-4b3a-8639-d8238eb77152

embeddings_a_3=httr::content(httr::POST(url="141.144.239.168/getEmbeddings",body=list("docs"=as.list(titles)),encode="json"))
embeddings_b_3=httr::content(httr::POST(url="141.144.239.168/getEmbeddings",body=list("docs"=as.list(titles2)),encode="json"))
embeddings_a_3=httr::content()
embeddings_a_3 = t(sapply(embeddings_a_3,function(f)f))
embeddings_b_3 = t(sapply(embeddings_b_3,function(f)f))


# Generate sentence embeddings 4 by ember
#-------------------------------------------------------------------------

# Get sentence embeddings of titles
require("httr")
model_id = "llmrails/ember-v1" 
e=list()
t0=Sys.time()
prompts=titles
e=list()
for(i in 1:length(prompts)){
  print(paste0(i,"/",length(prompts)," started at ",Sys.time()))
  payload=prompts[i]
  #payload = "Roses are red"
  url=paste0("https://api-inference.huggingface.co/models/",model_id)
  post=httr::POST(url=url, body=list("inputs"= payload), 
  	httr::add_headers(.headers=c("X-Wait-For-Model"="true","X-Use-Cache"="false")),	
	httr::add_headers(.headers=c("Authorization"=paste("Bearer",api_token))),
 	encode="json")
  x=httr::content(post)
  print(length(x[[1]][[1]]))
  e[[i]]=x
}
t1=Sys.time()
t1-t0
#sapply(e,length) 
sentenceEmbeddings = lapply(e,function(f){
  #x=do.call(cbind,f[[1]])
  #x=apply(x,2,as.numeric)
  #rowMeans(x) # Mean-Pooling der Token-Embeddings
  unlist(f)
})
embeddings_a_4=do.call(rbind,sentenceEmbeddings)
dim(embeddings_a_4)
write.csv2(embeddings_a_4,"embeddings_a_4.csv")
embeddings_a_4=read.csv2("embeddings_a_4.csv")[,-1]

# Get sentence embeddings of titles2
require("httr")
model_id = "llmrails/ember-v1" 
e=list()
t0=Sys.time()
prompts=titles2
e=list()
for(i in 1:length(prompts)){
  print(paste0(i,"/",length(prompts)," started at ",Sys.time()))
  payload=prompts[i]
  #payload = "Roses are red"
  url=paste0("https://api-inference.huggingface.co/models/",model_id)
  post=httr::POST(url=url, body=list("inputs"= payload), 
  	httr::add_headers(.headers=c("X-Wait-For-Model"="true","X-Use-Cache"="false")),	
	httr::add_headers(.headers=c("Authorization"=paste("Bearer",api_token))),
 	encode="json")
  x=httr::content(post)
  print(length(x[[1]][[1]]))
  e[[i]]=x
}
t1=Sys.time()
t1-t0
#sapply(e,length) 
sentenceEmbeddings = lapply(e,function(f){
  #x=as.matrix(wapply(f,function(x)(x)))
  #x=do.call(cbind,f[[1]])
  #x=apply(x,2,as.numeric)
  #rowMeans(x) # Mean-Pooling der Token-Embeddings
  unlist(f)
})
embeddings_b_4=do.call(rbind,sentenceEmbeddings)
dim(embeddings_b_4)
write.csv2(embeddings_b_4,"embeddings_b_4.csv")
embeddings_b_4=read.csv2("embeddings_b_4.csv")[,-1]


# Generate sentence embeddings 5 by #cross-en-de-roberta-sentence-transformer 
#-----------------------------------------------------------------------------

# Get sentence embeddings of titles via Huggingface API
require("httr")
model_id = "T-Systems-onsite/cross-en-de-roberta-sentence-transformer" 
e=list()
t0=Sys.time()
prompts=titles
e=list()
for(i in 1:length(prompts)){
  print(paste0(i,"/",length(prompts)," started at ",Sys.time()))
  payload=prompts[i]
  #payload = "Roses are red"
  url=paste0("https://api-inference.huggingface.co/models/",model_id)
  post=httr::POST(url=url, body=list("inputs"= payload), 
  	httr::add_headers(.headers=c("X-Wait-For-Model"="true","X-Use-Cache"="false")),	
	httr::add_headers(.headers=c("Authorization"=paste("Bearer",api_token))),
 	encode="json")
  x=httr::content(post)
  print(length(x[[1]][[1]]))
  e[[i]]=x
}
t1=Sys.time()
t1-t0
#sapply(e,length) 
sentenceEmbeddings = lapply(e,function(f){
  #x=as.matrix(wapply(f,function(x)(x)))
  x=do.call(cbind,f[[1]])
  x=apply(x,2,as.numeric)
  rowMeans(x) # Mean-Pooling der Token-Embeddings
})
embeddings_a_5=do.call(rbind,sentenceEmbeddings)
dim(embeddings_a_5)
write.csv2(embeddings_a_5,"embeddings_a_5.csv")
embeddings_a_5=read.csv2("embeddings_a_5.csv")[,-1]

# Get sentence embeddings of titles2 via Huggingface API
require("httr")
model_id = "T-Systems-onsite/cross-en-de-roberta-sentence-transformer" 
e=list()
t0=Sys.time()
prompts=titles2
e=list()
for(i in 1:length(prompts)){
  print(paste0(i,"/",length(prompts)," started at ",Sys.time()))
  payload=prompts[i]
  #payload = "Roses are red"
  url=paste0("https://api-inference.huggingface.co/models/",model_id)
  post=httr::POST(url=url, body=list("inputs"= payload), 
  	httr::add_headers(.headers=c("X-Wait-For-Model"="true","X-Use-Cache"="false")),	
	httr::add_headers(.headers=c("Authorization"=paste("Bearer",api_token))),
 	encode="json")
  x=httr::content(post)
  print(length(x[[1]][[1]]))
  e[[i]]=x
}
t1=Sys.time()
t1-t0
#sapply(e,length) 
sentenceEmbeddings = lapply(e,function(f){
  #x=as.matrix(wapply(f,function(x)(x)))
  x=do.call(cbind,f[[1]])
  x=apply(x,2,as.numeric)
  rowMeans(x) # Mean-Pooling der Token-Embeddings
})
embeddings_b_5=do.call(rbind,sentenceEmbeddings)
dim(embeddings_b_5)
write.csv2(embeddings_b_5,"embeddings_b_5.csv")
embeddings_b_5=read.csv2("embeddings_b_5.csv")[,-1]


# calculate similarities
#------------------------

x=embeddings_a_1 # wizardlm-embeddings of titles
y=embeddings_b_1 # wizardlm-embeddings of titles2
table(nchar(gsub(".*[.]","",as.character(unlist(x)))))
table(nchar(gsub(".*[.]","",as.character(unlist(y)))))
s1=sapply(1:dim(x)[1],function(i)
  sapply(1:dim(y)[1],function(j)
    lsa::cosine(as.numeric(x[i,]),as.numeric(y[j,]))
))
write.csv2(s1,"similarities_1.csv")

x=embeddings_a_2 # german-roberta-embeddings of titles
y=embeddings_b_2 # german-roberta-embeddings of titles
table(nchar(gsub(".*[.]","",as.character(unlist(x)))))
table(nchar(gsub(".*[.]","",as.character(unlist(y)))))
s2=sapply(1:dim(x)[1],function(i)
  sapply(1:dim(y)[1],function(j)
    lsa::cosine(as.numeric(x[i,]),as.numeric(y[j,]))
))
write.csv2(s2,"similarities_2.csv")

x=embeddings_a_2 # german-roberta-embeddings of titles
y=embeddings_b_2 # german-roberta-embeddings of titles
x=round(x)
y=round(y)
write.csv2(x,"embeddings_a_2quant0.csv")
write.csv2(y,"embeddings_b_2quant0.csv")
table(as.numeric(unlist(round(x))))
s2_quant0=sapply(1:dim(x)[1],function(i)
  sapply(1:dim(y)[1],function(j)
    lsa::cosine(as.numeric(x[i,]),as.numeric(y[j,]))
))
write.csv2(s2_quant0,"similarities_2_quant0.csv")

x=embeddings_a_2 # german-roberta-embeddings of titles
y=embeddings_b_2 # german-roberta-embeddings of titles
x=round(x,1)
y=round(y,1)
write.csv2(x,"embeddings_a_2quant1.csv")
write.csv2(y,"embeddings_b_2quant1.csv")
table(as.numeric(unlist(round(x,1))))
s2_quant1=sapply(1:dim(x)[1],function(i)
  sapply(1:dim(y)[1],function(j)
    lsa::cosine(as.numeric(x[i,]),as.numeric(y[j,]))
))
write.csv2(s2_quant1,"similarities_2_quant1.csv")

x=embeddings_a_3 # instructor-large-embeddings of titles
y=embeddings_b_3 # instructor-large-embeddings of titles2
table(nchar(gsub(".*[.]","",as.character(unlist(x)))))
table(nchar(gsub(".*[.]","",as.character(unlist(y)))))
s3=sapply(1:dim(x)[1],function(i)
  sapply(1:dim(y)[1],function(j)
    lsa::cosine(as.numeric(x[i,]),as.numeric(y[j,]))
))
write.csv2(s3,"similarities_3.csv")

x=embeddings_a_4 # ember-v1-embeddings of titles
y=embeddings_b_4 # ember-v1-embeddings of titles2
table(nchar(gsub(".*[.]","",as.character(unlist(x)))))
table(nchar(gsub(".*[.]","",as.character(unlist(y)))))
s4=sapply(1:dim(x)[1],function(i)
  sapply(1:dim(y)[1],function(j)
    lsa::cosine(as.numeric(x[i,]),as.numeric(y[j,]))
))
write.csv2(s4,"similarities_4.csv")


x=embeddings_a_5 # cross-en-de-roberta-sentence-transformer-embeddings of titles
y=embeddings_b_5 # cross-en-de-roberta-sentence-transformer-embeddings of titles2
table(nchar(gsub(".*[.]","",as.character(unlist(x)))))
table(nchar(gsub(".*[.]","",as.character(unlist(y)))))
s5=sapply(1:dim(x)[1],function(i)
  sapply(1:dim(y)[1],function(j)
    lsa::cosine(as.numeric(x[i,]),as.numeric(y[j,]))
))
write.csv2(s5,"similarities_5.csv")

x=embeddings_a_5 # cross-en-de-roberta-sentence-transformer-embeddings of titles
y=embeddings_b_5 # cross-en-de-roberta-sentence-transformer-embeddings of titles
x=round(x,0)
y=round(y,0)
write.csv2(x,"embeddings_a_5quant0.csv")
write.csv2(y,"embeddings_b_5quant0.csv")
table(as.numeric(unlist(round(x,1))))
s5_quant0=sapply(1:dim(x)[1],function(i)
  sapply(1:dim(y)[1],function(j)
    lsa::cosine(as.numeric(x[i,]),as.numeric(y[j,]))
))
write.csv2(s5_quant0,"similarities_5_quant1.csv")


x=embeddings_a_5 # cross-en-de-roberta-sentence-transformer-embeddings of titles
y=embeddings_b_5 # cross-en-de-roberta-sentence-transformer-embeddings of titles
x=round(x,1)
y=round(y,1)
write.csv2(x,"embeddings_a_5quant1.csv")
write.csv2(y,"embeddings_b_5quant1.csv")
table(as.numeric(unlist(round(x,1))))
s5_quant1=sapply(1:dim(x)[1],function(i)
  sapply(1:dim(y)[1],function(j)
    lsa::cosine(as.numeric(x[i,]),as.numeric(y[j,]))
))
write.csv2(s5_quant1,"similarities_5_quant1.csv")


# Evaluation
#------------
head(sort(table(titles),decreasing=T),10) # 6 Doubletten
doppelt=names(head(sort(table(titles),decreasing=T),6)) # streiche erste Nennung von Doppelungen
x1=s1[-match(doppelt,titles),-match(doppelt,titles)]
x2=s2[-match(doppelt,titles),-match(doppelt,titles)]
x2_quant0=s2_quant0[-match(doppelt,titles),-match(doppelt,titles)]
x2_quant1=s2_quant1[-match(doppelt,titles),-match(doppelt,titles)]
x3=s3[-match(doppelt,titles),-match(doppelt,titles)]
x4=s4[-match(doppelt,titles),-match(doppelt,titles)]
x5=s5[-match(doppelt,titles),-match(doppelt,titles)]
x5_quant0=s5_quant0[-match(doppelt,titles),-match(doppelt,titles)]
x5_quant1=s5_quant1[-match(doppelt,titles),-match(doppelt,titles)]

#s3=read.csv2("similarities_3.csv")[,-1]


x=c(
"cross-en-de-roberta-..."=mean(apply(x5,2,which.max)==1:dim(x5)[1]), 		 	#0.9311741
"cross-en-de-roberta-... (q1)"=mean(apply(x5_quant1,2,which.max)==1:dim(x5)[1]), 	#0.9311741
"german-roberta-v2 (q1)"=mean(apply(x2_quant1,2,which.max)==1:dim(x2)[1]), 	 	# 0.9230769 for german-roberta-embeddings quant1
"german-roberta-v2"=mean(apply(x2,2,which.max)==1:dim(x2)[1]), 		 	 	# 0.9190283 for german-roberta-embeddings quant18
"instructor-large"=mean(apply(x3,2,which.max)==1:dim(x1)[1]), 	 		 	# 0.8987854 for instructor-large-embeddings quant18
"ember-v1"=mean(apply(x4,2,which.max)==1:dim(x4)[1]),				 	# 0.8542510 for ember-v1-embeddings quant18
"cross-en-de-roberta-... (q0)"=mean(apply(x5_quant0,2,which.max)==1:dim(x5)[1]), 	# 0.9311741
"german-roberta-v2 (q0)"=mean(apply(x2_quant0,2,which.max)==1:dim(x2)[1]), 	 	# 0.7894737 for german-roberta-embeddings quant0
"WizardLM-13B-v1.2     \n(decoder-only)"=mean(apply(x1,2,which.max)==1:dim(x1)[1]) 	# 0.4129555 for wizardlm-embeddings quant18
)

dev.new(width=14,height=7)
qqBaseX::bp(round(x*100,2),mar=par("mar")*c(2.5,1,1,1),add.numbers="%",main1="Anteil richtiger Zuordnungen synonymer Projekttitel",ylim=c(0,100))
t1=titles[-match(doppelt,titles)]
t2=titles2[-match(doppelt,titles)]

w=which(apply(x2,2,which.max)!=1:dim(x2)[1]);w # untersuche best matches im Falle von "Fehlzuordnungen"
x=sapply(w,function(i){c(
	"i"=i,
	"t1"=t1[i],
	"t2"=t2[i],
	#head(t2[order(x2[,i], decreasing=T)])  
	#apply(x2,1,which.max)[i]	
	"bestMatch"=apply(x2,2,which.max)[i], 
	"best t2"=t2[apply(x2,2,which.max)[i]],
	"best t1"=t1[apply(x2,2,which.max)[i]])
})
write.csv2(x,"mismatches.csv")

