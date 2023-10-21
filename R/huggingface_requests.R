#################
# Basic Examples
#################

# Transformers
#--------------

#!/usr/bin/Rscript
require("httr")
model_id = "tiiuae/falcon-7b-instruct" #tiiuae/falcon-7b
payload = "What is the definition of complex problem solving?"
params=list("max_new_tokens"=300, return_full_text=F)
url=paste0("https://api-inference.huggingface.co/models/",model_id)
post=httr::POST(url=url, body=list("inputs"=payload, "parameters"=params),
  #httr::add_headers(.headers=c("Authorization"=paste("Bearer",api_token))),
  httr::add_headers(.headers=c("X-Wait-For-Model"="true","X-Use-Cache"="false")),	
  encode="json")
httr::content(post)

#!/usr/bin/Rscript
require("httr")
model_id = "google/flan-t5-large" # cf. "google/flan-ul2", "akosal/LongForm-T5-xl", MBZUAI/LaMini-Flan-T5-783M 
payload = "Please write a step by step recipe to make bolognese pasta."
params=list("max_length"=200, "length_penalty"=2, "num_beams"=16, "early_stopping"=TRUE)
url=paste0("https://api-inference.huggingface.co/models/",model_id)
post=httr::POST(url=url, body=list("inputs"=payload, "parameters"=params), encode="json")
httr::content(post)

##!/usr/bin/env python
#import requests
#model_id = "google/flan-t5-xl" 
#payload = "Please write a step by step recipe to make bolognese pasta."
#params={"max_length":200, "length_penalty":2, "num_beams":16, "early_stopping":True}
#url = f"https://api-inference.huggingface.co/models/{model_id}"
#post = requests.post(url, json={"inputs":payload, "parameters":params})
#post.json()

##!/bin/bash
#model_id="google/flan-t5-xl" 
#payload="Please write a step by step recipe to make bolognese pasta."
#params='{"max_length":200, "length_penalty":2, "num_beams":16, "early_stopping":true}'
#url="https://api-inference.huggingface.co/models/"$model_id
#data='{"inputs":"'$payload'","parameters":'$params'}'
#post=$(curl -X POST $url -H "Content-Type: application/json" --data-raw "$data")
#echo $post

##!/bin/bash
#model_id="bigscience/bloom" 
#payload="The following email explains two things:\n1) The writer, Andy, is going to miss work.\n2)The receiver, Betty, is Andy's boss and can email if #anything needs to be done.\n\nFrom:"
#params='{"max_new_tokens": 200, "return_full_text":false}'
#url="https://api-inference.huggingface.co/models/"$model_id
#data='{"inputs":"'$payload'","parameters":'$params'}'
#post=$(curl -X POST $url -H "Content-Type: application/json" --data-raw "$data")
#echo $post


# Diffusers
#------------------

#!/usr/bin/Rscript
require("httr")
payload = "obi wan kenobi, screenshot in a typical pixar movie, disney infinity 3 star wars style, volumetric lighting, subsurface scattering, photorealistic, octane render, medium shot, studio ghibli, pixar and disney animation, sharp, rendered in unreal engine 5, anime key art by greg rutkowski and josh black, bloom, dramatic lighting"
model_id = "stabilityai/stable-diffusion-2-1"
params=list("num_inference_steps"=100)
url=paste0("https://api-inference.huggingface.co/models/",model_id)
post=httr::POST(url=url, body=list("inputs"= payload, "parameters"=params), 
  	httr::add_headers(.headers=c("X-Wait-For-Model"="true","X-Use-Cache"="false")),	
 	encode="json")
img=httr::content(post)
png::writePNG(img,paste0("image_",as.numeric(Sys.time()),".png"))


#########################
# Exemplary Transformers
#########################

model_ids=c(
  "tiiuae/falcon-7b-instruct",
  "tiiuae/falcon-7b",	

  "google/flan-ul2",
  "google/flan-t5-large", 
  "google/flan-t5-xl", 

  "EleutherAI/gpt-neox-20b",
  "EleutherAI/gpt-j-6B",

  "bigscience/bloom",
  "bigscience/bloom-petals",

  "bigscience/bloomz-560m",
  "bigscience/bloomz-7b1",
  "bigscience/bloomz-3b",
  "bigscience/bloomz-1b1",
  "bigscience/bloomz-1b7",

  "bigscience/T0",
  "bigscience/T0p",
  "bigscience/T0pp",
  "bigscience/T0_3B",  

  "bigscience/mt0-base",
  "bigscience/mt0-xxl",
  "bigscience/mt0-xl",

  "facebook/opt-iml-30b",
  "facebook/opt-iml-max-1.3b"
)

bot=function(
  model_id=model_ids[1],
  payload=paste0(
	"The following email explains two things:\n",
	"1) The writer, Andy, is going to miss work.\n",
	"2) The receiver, Betty, is Andy's boss and can email if anything needs to be done.\n",
	"\nFrom:"),
  params=list("max_length"=200,"num_beams"=16, "early_stopping"=TRUE) #,length_penalty"=2, "min_length"=200, "return_full_text"=FALSE
){ 
  url=paste0("https://api-inference.huggingface.co/models/",model_id)
  post=httr::POST(url=url, body=list("inputs"=payload, "parameters"=params), 
  	httr::add_headers(.headers=c("X-Wait-For-Model"="true","X-Use-Cache"="false")),	
	#httr::add_headers(.headers=c("Authorization"=paste("Bearer",api_token))),
	encode="json")
  httr::content(post)
}


# Selected resonses:
#--------------------

bot("google/flan-t5-large")
# Output of flan-t5-large:
# "Andy: I'm going to miss work. Can you email me if anything needs to be done?"

bot("bigscience/bloom",
	params=list("max_new_tokens"=200,"num_beams"=16, "early_stopping"=TRUE))
# Output of bloom:
# "The following email explains two things:\n1) The writer, Andy, is going to miss work.\n2) The receiver, Betty, is Andy's boss and can email if anything needs to be done.\n\nFrom: Andy <andy@company.com>\nTo: Betty <betty@company.com>\nSubject: I am going to miss work tomorrow\nDate: Mon, 1 Feb 2016 10:45:00 +0000\n\nI am going to miss work tomorrow. I have a doctor's appointment. I will be\n  back on Tuesday.\n\nA:\n\nI am going to miss work tomorrow. I have a doctor's appointment. I\n  will be back on Tuesday.\n\nThis is a perfectly fine way to write an email. It is clear, concise, and to the point. It is also a good example of how to write an email in the future tense."

bot("EleutherAI/gpt-j-6B",
	params=list("max_length"=300, "length_penalty"=2, "num_beams"=1, "early_stopping"=TRUE,"return_full_text"=FALSE))
#" Andy  <andy_sales@hotmail.com>\nDate: Mon, 2 Oct 2000 19:26:32 -0400\n>Date: Sunday, October 01, 2000 10:41:47 PM\n>To: Betty Smith <ladybarb@hotmail.com>\n> Subject: Fwd: Fw: [IMG]\n>\n>\n>\n>>\n>>\n>>From: Andy Tichy <andy_sales@hotmail.com>\n>>To: \"Betty & John\" <bettyandjohn@hotmail.com>, \"Beth\"\n>> <barb.tichy@fas.com>, \"Betty & John\" <bettyandjohn@hotmail.com>,\n>>\"Butterball\" <b@r-tech.net>, \"Bun\" <bonaduce@hotmail.com>, \"C. & V\"\n>><candysalecat@hotmail.com>, \"Carol\" <c@cs.com>, \"Charlie\"\n>><charlie_sales@hotmail.com>, \"Chloe & John\" <mwatson6@"


# Compare several models: 
#------------------------

working_ids=c(1,2,5,10,11,15,16,18)
#4: num_beams too much for CUDA
#12,14: no parameters allowed (Internal Server Error without parameters)
#17: model overloaded
#other: model time out

for(i in working_ids){
	print(Sys.time())
	message(paste0(i,". ",model_ids[i],":\n",bot(model_ids[i])))
}


